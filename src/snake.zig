// Author: Dylan Turner
// Description: Define game objects that make up the snake (head and bodies)

const sdl = @import("sdl.zig");
const res = @import("res.zig");

pub const SnakeHead = struct {
    spr: res.Sprite,

    pub fn init(renderer: *sdl.Renderer) !SnakeHead {
        var spr = try res.Sprite.init(@ptrCast(*const u8, "img/head.png"), renderer);
        spr.scale_x = 2.0;
        spr.scale_y = 2.0;
        spr.x = 100;
        spr.y = 100;
        
        return SnakeHead {
            .spr = spr
        };
    }
};

