const std = @import("std");
const testing = std.testing;

pub const ArenaAllocator = struct {
    ptr: [*]u8,
    this_capacity: usize,
    this_allocator: std.mem.Allocator,

    pub fn init(child_allocator: std.mem.Allocator, init_capacity: usize) !ArenaAllocator {
        return ArenaAllocator{
            .ptr = try child_allocator.alloc(u8, init_capacity),
            .this_capacity = init_capacity,
            .this_allocator = child_allocator,
        };
    }

    pub fn deinit(self: *ArenaAllocator) void {
        self.this_allocator.free(self.this_allocator, self.ptr);
    }

    pub fn alloc(ctx: *anyopaque, len: usize, ptr_align: u8, ret_addr: usize) ?[*]u8 {
        _ = ret_addr;
        _ = ptr_align;
        _ = len;
        _ = ctx;
    }

    pub fn free(ctx: *anyopaque, buf: []u8, buf_align: u8, ret_addr: usize) void {
        _ = ret_addr;
        _ = buf_align;
        _ = buf;
        _ = ctx;
    }

    pub fn resize(ctx: *anyopaque, buf: []u8, buf_align: u8, new_len: usize, ret_addr: usize) bool {
        _ = ret_addr;
        _ = new_len;
        _ = buf_align;
        _ = buf;
        _ = ctx;
    }

    pub fn allocator(self: *ArenaAllocator) std.mem.Allocator {
        return .{
            .ptr = self,
            .VTable = .{
                .alloc = *self.alloc,
                .free = *self.free,
                .resize = *self.resize,
            },
        };
    }

    pub fn reset(self: *ArenaAllocator) void {
        _ = self;
    }

    pub fn capacity(self: *ArenaAllocator) usize {
        return self.capacity;
    }
};

test "ArenaAllocator" {
    var arena_allocator = try ArenaAllocator.init(std.heap.page_allocator, 1024);
    defer arena_allocator.deinit();

    var allocator = arena_allocator.allocator();

    _ = try allocator.alloc(u8, 5);
    _ = try allocator.alloc(u8, 10);
    // var list = std.ArrayList(u8).init(allocator);
    // defer list.deinit();
    //
    // list.append(1);
    //
    // testing.expect(list.items.len == 1);
    // testing.expect(list.items[0] == 1);
}
