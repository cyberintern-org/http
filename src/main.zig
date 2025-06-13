const std = @import("std");
const http = @import("http");

pub fn main() !void {
    const address = std.net.Address.initIp4(.{ 127, 0, 0, 1 }, 12345);
    try http.listenAndServe(address);
}
