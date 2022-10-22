// Author: Dylan Turner
// Description: Define game objects that make up the snake (head and bodies)

const sdl = @import("sdl.zig");
const res = @import("res.zig");
const settings = @import("settings.zig");
const std = @import("std");

// Actually the Snake*Head*, but ya know it's also the "main" part of the snake, so yeah
// When creating, use "defer sdl.destroyTexture(<var-name>.spr.tex)"
pub const Snake = struct {
    spr: res.Sprite,
    x: f32,
    y: f32,
    spd: u32,
    sec_tmr: std.time.Timer,

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
            .sec_tmr = try std.time.Timer.start()
        };
    }

    pub fn update(snake: *Snake, dt: f32) void {
        if(snake.sec_tmr.read() < std.time.ns_per_s) {
            snake.x += @intToFloat(f32, snake.spd) * dt;
            snake.spr.x = snake.x;
        }
    }

    pub fn draw(snake: *const Snake, renderer: *sdl.Renderer) void {
        snake.spr.draw(renderer);
    }
};

