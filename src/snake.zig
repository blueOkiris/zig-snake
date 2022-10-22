// Author: Dylan Turner
// Description: Define game objects that make up the snake (head and bodies)

const sdl = @import("sdl.zig");
const res = @import("res.zig");
const settings = @import("settings.zig");
const std = @import("std");

// Actually the Snake*Head*, but ya know it's also the "main" part of the snake, so yeah
pub const Snake = struct {
    spr: res.Sprite,
    x: f32,
    y: f32,
    spd: u32,
    sec_tmr: f64,
    started: bool,

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
            .sec_tmr = 0.0,
            .started = false
        };
    }

    pub fn update(snake: *Snake, dt: f64) void {
        if(snake.started) {
            if(snake.sec_tmr < 1.0) {
                snake.x += @intToFloat(f32, snake.spd) * @floatCast(f32, dt);
                snake.spr.x = snake.x;
                snake.sec_tmr += dt;
            } else {
                snake.started = false;
            }
        } else {
            const kb_state = sdl.getKeyboardState(null);
            if(kb_state[sdl.SCANCODE_SPACE] != 0) {
                snake.sec_tmr = 0.0;
                snake.x = 100;
                snake.started = true;
            }
        }
    }

    pub fn draw(snake: *const Snake, renderer: *sdl.Renderer) void {
        snake.spr.draw(renderer);
    }

    pub fn deinit(snake: *Snake) void {
        snake.spr.deinit();
    }
};

