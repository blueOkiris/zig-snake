// Author: Dylan Turner
// Description: Define game objects that make up the snake (head and bodies)

const std = @import("std");
const sdl = @import("sdl.zig");
const res = @import("res.zig");
const settings = @import("settings.zig");

// Actually the Snake*Head*, but ya know it's also the "main" part of the snake, so yeah
pub const Snake = struct {
    spr: res.Sprite,
    x: f32,
    y: f32,
    tile_x: f32,
    tile_y: f32,
    spd: u32,
    bodies: std.ArrayList(Body),
    dead: bool,
    dir: u8,
    right_pressed: bool,
    down_pressed: bool,
    left_pressed: bool,
    up_pressed: bool,

    pub fn init(renderer: *sdl.Renderer) !Snake {
        // Create initial bodies (3 currently) and use it to set the start location
        var start_body = try Body.init(renderer);
        start_body.x = ((settings.WINDOW_WIDTH / 32) / 2) * 32;
        start_body.y = ((settings.WINDOW_HEIGHT / 32) / 2) * 32;
        start_body.par_tile_x = start_body.x;
        start_body.par_tile_y = start_body.y;
        start_body.following = false;

        var bodies = std.ArrayList(Body).init(std.heap.page_allocator);
        try bodies.append(start_body);
        start_body.x -= 32;
        start_body.following = true;
        try bodies.append(start_body);
        (&bodies.items[1]).parent = &bodies.items[0];
        
        start_body.x += 64; // Set up for head location

        var spr = try res.Sprite.init(@ptrCast(*const u8, "img/head.png"), renderer);
        spr.x = start_body.x;
        spr.y = start_body.y;

        return Snake {
            .spr = spr,
            .x = start_body.x,
            .y = start_body.y,
            .tile_x = start_body.x - 32,
            .tile_y = start_body.y,
            .spd = settings.DEF_SNAKE_SPD,
            .bodies = bodies,
            .dead = false,
            .dir = 0,
            .right_pressed = false,
            .down_pressed = false,
            .left_pressed = false,
            .up_pressed = false
        };
    }

    pub fn update(snake: *Snake, dt: f64) void {
        if(snake.dead) {
            return;
        }

        // Only draw snapped grid
        var new_tile_x = @trunc(@floor(snake.x) / 32) * 32;
        var new_tile_y = @trunc(@floor(snake.y) / 32) * 32;
        if(@fabs(snake.tile_x - new_tile_x) >= 31.5) {
            snake.bodies.items[0].x = snake.tile_x;
            snake.bodies.items[0].y = snake.tile_y;
            snake.bodies.items[0].rot = @intToFloat(f64, snake.dir) * 90;

            snake.spr.x = new_tile_x;
            snake.tile_x = new_tile_x;
        }
        if(@fabs(snake.tile_y - new_tile_y) >= 32.0) {
            snake.bodies.items[0].x = snake.tile_x;
            snake.bodies.items[0].y = snake.tile_y;
            snake.bodies.items[0].rot = @intToFloat(f64, snake.dir) * 90;

            snake.spr.y = new_tile_y;
            snake.tile_y = new_tile_y;
        }
                
        // Have bodies update. Reverse order for properly following
        var i: usize = snake.bodies.items.len;
        while(i > 0) {
            var body = &snake.bodies.items[i - 1];
            body.update(dt);
            i -= 1;
        }

        // Move
        if(snake.dir == 0) {
            snake.x += @floatCast(f32, @intToFloat(f64, snake.spd) * dt);
        } else if(snake.dir == 1) {
            snake.y += @floatCast(f32, @intToFloat(f64, snake.spd) * dt);
        } else if(snake.dir == 2) {
            snake.x -= @floatCast(f32, @intToFloat(f64, snake.spd) * dt);
        } else if(snake.dir == 3) {
            snake.y -= @floatCast(f32, @intToFloat(f64, snake.spd) * dt);
        }

        // Update dirs
        const kb_state = sdl.getKeyboardState(null);
        if(kb_state[sdl.SCANCODE_RIGHT] != 0 and !snake.right_pressed) {
            // Transfer distance moved to new direction
            if(snake.dir == 1) {
                const diff = snake.y - snake.tile_y;
                snake.x = snake.tile_x + diff;
                snake.y = snake.tile_y;
            } else if(snake.dir == 2) {
                const diff = snake.tile_x + 32.0 - snake.x;
                snake.x = snake.tile_x + diff;
                snake.y = snake.tile_y;
            } else if(snake.dir == 3) {
                const diff = snake.tile_y + 32.0 - snake.y;
                snake.x = snake.tile_x + diff;
                snake.y = snake.tile_y;
            }

            snake.dir = 0;

            snake.right_pressed = true;
        } else if(kb_state[sdl.SCANCODE_RIGHT] == 0) {
            snake.right_pressed = false;
        }
        if(kb_state[sdl.SCANCODE_LEFT] != 0 and !snake.left_pressed) {
            // Transfer distance moved to new direction
            if(snake.dir == 0) {
                const diff = snake.x - snake.tile_x;
                snake.x = snake.tile_x + 32.0 - diff;
                snake.y = snake.tile_y;
            } else if(snake.dir == 1) {
                const diff = snake.y - snake.tile_y;
                snake.x = snake.tile_x + 32.0 - diff;
                snake.y = snake.tile_y;
            } else if(snake.dir == 3) {
                const diff = snake.tile_y + 32.0 - snake.y;
                snake.x = snake.tile_x + 32.0 - diff;
                snake.y = snake.tile_y;
            }

            snake.dir = 2;

            snake.left_pressed = true;
        } else if(kb_state[sdl.SCANCODE_LEFT] == 0) {
            snake.left_pressed = false;
        }
        if(kb_state[sdl.SCANCODE_DOWN] != 0 and !snake.down_pressed) {
            // Transfer distance moved to new direction
            if(snake.dir == 0) {
                const diff = snake.x - snake.tile_x;
                snake.x = snake.tile_x;
                snake.y = snake.tile_y + diff;
            } else if(snake.dir == 2) {
                const diff = snake.tile_x + 32.0 - snake.x;
                snake.x = snake.tile_x;
                snake.y = snake.tile_y + diff;
            } else if(snake.dir == 3) {
                const diff = snake.tile_y + 32.0 - snake.y;
                snake.x = snake.tile_x;
                snake.y = snake.tile_y + diff;
            }

            snake.dir = 1;

            snake.down_pressed = true;
        } else if(kb_state[sdl.SCANCODE_DOWN] == 0) {
            snake.down_pressed = false;
        }
        if(kb_state[sdl.SCANCODE_UP] != 0 and !snake.up_pressed) {
            // Transfer distance moved to new direction
            if(snake.dir == 0) {
                const diff = snake.x - snake.tile_x;
                snake.x = snake.tile_x;
                snake.y = snake.tile_y + 32.0 - diff;
            } else if(snake.dir == 1) {
                const diff = snake.tile_y - snake.y;
                snake.x = snake.tile_x;
                snake.y = snake.tile_y + 32.0 - diff;
            } else if(snake.dir == 2) {
                const diff = snake.tile_x + 32.0 - snake.x;
                snake.x = snake.tile_x;
                snake.y = snake.tile_y + 32.0 - diff;
            }

            snake.dir = 3;

            snake.up_pressed = true;
        } else if(kb_state[sdl.SCANCODE_UP] == 0) {
            snake.up_pressed = false;
        }

        // Die from walls
        if((new_tile_x < 32) or (new_tile_x > (settings.WINDOW_WIDTH / 32) * 32 - 63.5)
                or (new_tile_y < 32) or (new_tile_y > (settings.WINDOW_HEIGHT / 32) * 32 - 63.5)) {
            snake.dead = true;
            i = 0;
            while(i < snake.bodies.items.len) {
                var body = &snake.bodies.items[i];
                body.following = false;
                i += 1;
            }
        }

        // Die from running into ourself
        i = 0;
        while(i < snake.bodies.items.len) {
            var body = &snake.bodies.items[i];

            if((@fabs(body.x - snake.tile_x) < 32) and (@fabs(body.y - snake.tile_y) < 32)) {
                snake.dead = true;
                i = 0;
                while(i < snake.bodies.items.len) {
                    var body2 = &snake.bodies.items[i];
                    body2.following = false;
                    i += 1;
                }
                break;
            }

            i += 1;
        }
    }

    pub fn draw(snake: *const Snake, renderer: *sdl.Renderer) void {
        for(snake.bodies.items) |body| {
            body.draw(renderer);
        }

        // Draw spr last so head is on top
        snake.spr.draw_rotated(renderer, @intToFloat(f64, snake.dir) * 90);
    }

    pub fn deinit(snake: *Snake) void {
        snake.spr.deinit();
        var i: u32 = 0;
        while(i < snake.bodies.items.len) {
            var body = &snake.bodies.items[i];
            body.deinit();
            i += 1;
        }
        snake.bodies.deinit();
    }
};

// I designed Sprite poorly for reuse, so now I've got a singleton thingy sort of
// It's whatever. It's pretty clear that I auto init/deinit the BODY_SPR once, not too unmanageable
// If it becomes a problem I'll refactor
var BODY_SPR_INITTED: bool = false;
var BODY_SPR_DEINITTED: bool = false;
var BODY_SPR: res.Sprite = undefined;

const Body = struct {
    x: f32,
    y: f32,
    par_tile_x: f32,
    par_tile_y: f32,
    par_rot: f64,
    parent: *Body,
    following: bool,
    rot: f64,

    pub fn init(renderer: *sdl.Renderer) !Body {
        if(!BODY_SPR_INITTED) {
            BODY_SPR = try res.Sprite.init(@ptrCast(*const u8, "img/body.png"), renderer);
            BODY_SPR_INITTED = true;
            BODY_SPR_DEINITTED = false;
        }
        return Body {
            .x = 0.0,
            .y = 0.0,
            .par_tile_x = 0.0,
            .par_tile_y = 0.0,
            .par_rot = 0.0,
            .parent = undefined,
            .following = false,
            .rot = 0.0
        };
    }

    pub fn update(body: *Body, _: f64) void {
        if(!body.following) {
            return;
        }

        // Parent will have follow off and be controlled by head. All others will follow
        // To add new ones, just append and point to the end of ArrayList
        if(@fabs(body.parent.x - body.par_tile_x) >= 31.5) {
            body.x = body.par_tile_x;
            body.y = body.par_tile_y;
            body.par_tile_x = body.parent.x;

            body.rot = body.par_rot;
            body.par_rot = body.parent.rot;
        }
        if(@fabs(body.parent.y - body.par_tile_y) >= 31.5) {
            body.x = body.par_tile_x;
            body.y = body.par_tile_y;
            body.par_tile_y = body.parent.y;

            body.rot = body.par_rot;
            body.par_rot = body.parent.rot;
        }
    }

    pub fn draw(body: *const Body, renderer: *sdl.Renderer) void {
        BODY_SPR.x = body.x;
        BODY_SPR.y = body.y;
        BODY_SPR.draw_rotated(renderer, body.rot);
    }

    pub fn deinit(_: *Body) void {
        if(!BODY_SPR_DEINITTED) {
            BODY_SPR.deinit();
            BODY_SPR_DEINITTED = true;
            BODY_SPR_INITTED = false;
        }
    }
};

