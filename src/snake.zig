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
            .dead = false
        };
    }

    pub fn update(snake: *Snake, dt: f64) void {
        if(snake.dead) {
            return;
        }

        // Only draw snapped grid
        var new_tile_x = @trunc(@floor(snake.x) / 32) * 32;
        var new_tile_y = @trunc(@floor(snake.y) / 32) * 32;
        if(@fabs(snake.tile_y - new_tile_y) >= 32.0) {
            snake.bodies.items[0].x = snake.tile_x;

            snake.spr.y = new_tile_y;
            snake.tile_y = new_tile_y;
        }
        if(@fabs(snake.tile_x - new_tile_x) >= 31.5) {
            snake.bodies.items[0].x = snake.tile_x;

            snake.spr.x = new_tile_x;
            snake.tile_x = new_tile_x;
        }
        
        // Have bodies update
        var i: u32 = 0;
        while(i < snake.bodies.items.len) {
            var body = &snake.bodies.items[i];
            body.update(dt);
            i += 1;
        }

        // Move
        snake.x += @floatCast(f32, @intToFloat(f64, snake.spd) * dt);

        // Die from walls
        if(new_tile_x > settings.WINDOW_WIDTH - 63.5) {
            snake.dead = true;
            i = 0;
            while(i < snake.bodies.items.len) {
                var body = &snake.bodies.items[i];
                body.following = false;
                i += 1;
            }
        }
    }

    pub fn draw(snake: *const Snake, renderer: *sdl.Renderer) void {
        snake.spr.draw(renderer);
        for(snake.bodies.items) |body| {
            body.draw(renderer);
        }
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
    parent: *Body,
    following: bool,

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
            .parent = undefined,
            .following = false
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
            body.par_tile_x = body.parent.x;
        }
        if(@fabs(body.parent.y - body.par_tile_y) >= 31.5) {
            body.y = body.par_tile_y;
            body.par_tile_y = body.parent.y;
        }
    }

    pub fn draw(body: *const Body, renderer: *sdl.Renderer) void {
        BODY_SPR.x = body.x;
        BODY_SPR.y = body.y;
        BODY_SPR.draw(renderer);
    }

    pub fn deinit(_: *Body) void {
        if(!BODY_SPR_DEINITTED) {
            BODY_SPR.deinit();
            BODY_SPR_DEINITTED = true;
            BODY_SPR_INITTED = false;
        }
    }
};

