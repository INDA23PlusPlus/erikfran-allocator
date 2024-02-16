const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

pub const LinearAllocator = struct {
    index: usize,
    buf: []u8,

    pub fn init(buf: []u8) !LinearAllocator {
        return LinearAllocator{
            // .ptr = child_allocator.rawAlloc(init_capacity, 8, @returnAddress()) orelse return error.OutOfMemory,
            .index = 0,
            .buf = buf,
        };
    }

    // pub fn deinit(self: *ArenaAllocator) void {
    //     // self.this_allocator.rawFree(self.ptr.*, 8, @returnAddress());
    // }

    pub fn alloc(ctx: *anyopaque, len: usize, ptr_align: u8, _: usize) ?[*]u8 {
        var self: *LinearAllocator = @ptrCast(@alignCast(ctx));

        std.debug.print("{d}, {d}, {d}, {d}\n", .{ self.index, len, self.buf.len, ptr_align });

        if ((self.index + len > self.buf.len) or (ptr_align <= 0)) {
            std.debug.print("{d}, {d}, {d}, {d}\n", .{ self.index, len, self.buf.len, ptr_align });
            return null;
        }

        const alignment: usize = @as(usize, 1) << @truncate(ptr_align);
        const new_index = self.index + len;
        const align_offset: usize = ~(alignment - 1) & new_index;
        const aligned_index = new_index + align_offset;

        defer self.index += aligned_index;
        return @ptrFromInt(self.index);
    }

    pub fn free(_: *anyopaque, _: []u8, _: u8, _: usize) void {}

    pub fn resize(_: *anyopaque, _: []u8, _: u8, _: usize, _: usize) bool {
        return false;
    }

    pub fn allocator(self: *LinearAllocator) Allocator {
        return .{
            .ptr = self,
            .vtable = &.{
                .alloc = alloc,
                .free = free,
                .resize = resize,
            },
        };
    }
};

pub fn main() !void {
    var buf: [1000000]u8 = undefined;
    var linear_allocator = try LinearAllocator.init(&buf);

    var allocator = linear_allocator.allocator();

    try std.heap.testAllocator(allocator);
    try std.heap.testAllocatorAligned(allocator);
    try std.heap.testAllocatorLargeAlignment(allocator);

    _ = try allocator.alloc(u8, 5);
    _ = try allocator.alloc(u8, 10);
}

test "Linear Allocator" {
    var buf: [1000000]u8 = undefined;
    var linear_allocator = try LinearAllocator.init(&buf);

    var allocator = linear_allocator.allocator();

    try std.heap.testAllocator(allocator);
    try std.heap.testAllocatorAligned(allocator);
    try std.heap.testAllocatorLargeAlignment(allocator);

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
