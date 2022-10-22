// Author: Dylan Turner
// Description: Define game objects that make up the snake (head and bodies)

const sdl = @import("sdl.zig");
const res = @import("res.zig");
const settings = @import("settings.zig");
const std = @import("std");

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

    state: SnakeState,

    pub fn init(renderer: *sdl.Renderer) !Snake {
        var spr = try res.Sprite.init(@ptrCast(*const u8, "img/head.png"), renderer);
        spr.scale_x = 2.0;
        spr.scale_y = 2.0;
        spr.x = 100;
        spr.y = 100;
        
        return Snake {
            .spr = spr,
            .x = 100,
            .y = 100,
            .spd = settings.DEF_SNAKE_SPD,
            .state = SnakeState.Invisible
        };
    }

    pub fn update(_: *Snake, _: f64) void {

    }

    pub fn draw(snake: *const Snake, renderer: *sdl.Renderer) void {
        if(snake.state != SnakeState.Invisible) {
            snake.spr.draw(renderer);
        }
    }

    pub fn deinit(snake: *Snake) void {
        snake.spr.deinit();
    }
};

