// Author: Dylan Turner
// Description: Define game objects that make up the snake (head and bodies)

const std = @import("std");
const sdl = @import("sdl.zig");
const res = @import("res.zig");
const settings = @import("settings.zig");

pub const SnakeState = enum {
    Invisible,
    Reset,
    Moving,
    Eating,
    Dead
};

// Actually the Snake*Head*, but ya know it's also the "main" part of the snake, so yeah
pub const Snake = struct {
    spr: res.Sprite,
    x: f32,
    y: f32,
    spd: u32,
    bodies: std.ArrayList(Body),

    state: SnakeState,

    pub fn init(renderer: *sdl.Renderer) !Snake {
        // Create initial bodies (3 currently)
        var start_body = try Body.init(renderer);
        start_body.x = ((settings.WINDOW_WIDTH / 32) / 2 - 1) * 32;
        start_body.y = ((settings.WINDOW_HEIGHT / 32) / 2) * 32;
        var bodies = std.ArrayList(Body).init(std.heap.page_allocator);
        try bodies.append(start_body);
        start_body.x += 32;
        try bodies.append(start_body);
        start_body.x += 32; // Set up for head location

        return Snake {
            .spr = try res.Sprite.init(@ptrCast(*const u8, "img/head.png"), renderer),
            .x = start_body.x,
            .y = start_body.y,
            .spd = settings.DEF_SNAKE_SPD,
            .bodies = bodies,
            .state = SnakeState.Invisible
        };
    }

    pub fn update(snake: *Snake, dt: f64) void {
        snake.spr.x = snake.x;
        snake.spr.y = snake.y;

        var i: u32 = 0;
        while(i < snake.bodies.items.len) {
            var body = &snake.bodies.items[i];
            body.update(dt);
            i += 1;
        }
    }

    pub fn draw(snake: *const Snake, renderer: *sdl.Renderer) void {
        switch(snake.state) {
            SnakeState.Invisible => {},
            else => {
                snake.spr.draw(renderer);
                for(snake.bodies.items) |body| {
                    body.draw(renderer);
                }
            }
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

    pub fn init(renderer: *sdl.Renderer) !Body {
        if(!BODY_SPR_INITTED) {
            BODY_SPR = try res.Sprite.init(@ptrCast(*const u8, "img/body.png"), renderer);
            BODY_SPR_INITTED = true;
        }
        return Body {
            .x = 0.0,
            .y = 0.0
        };
    }

    pub fn update(_: *Body, _: f64) void {
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
        }
    }
};

