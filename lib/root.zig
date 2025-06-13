const std = @import("std");

pub fn listenAndServe(address: std.net.Address) !void {
    var server = try address.listen(.{ .reuse_port = true });
    defer server.deinit();

    std.log.info("[{}] Listening on {}", .{ std.time.timestamp(), address });
    while (true) {
        const conn = try server.accept();
        defer conn.stream.close();

        std.log.info("[{}] Accepted connection from {}", .{ std.time.timestamp(), conn.address });

        try conn.stream.writeAll("HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 13\r\n\r\nHello, World!");
    }
}
