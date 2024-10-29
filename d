#!/bin/bash
# CVE-2022-22721 - Apache HTTP Server mod_lua DoS (Custom Installation)

# Cài đặt các gói cần thiết
apt-get update && apt-get install -y \
    apache2 \
    lua5.3 \
    liblua5.3-dev \
    apache2-dev \
    build-essential \
    wget

# Tải và biên dịch mod_lua cho Apache
cd /tmp
wget https://archive.apache.org/dist/httpd/httpd-2.4.46.tar.gz
tar -xzvf httpd-2.4.46.tar.gz
cd httpd-2.4.46/modules/lua
apxs -I/usr/include/lua5.3 -cia mod_lua.c

# Kiểm tra xem quá trình biên dịch có thành công không
if [ $? -ne 0 ]; then
    echo "Biên dịch mod_lua thất bại. Kiểm tra lại các bước cài đặt."
    exit 1
fi

# Thêm cấu hình Lua vào Apache để kích hoạt Lua scripting
echo '
<IfModule mod_lua.c>
    <Location /lua>
        SetHandler lua-script
        LuaCodeCache off
    </Location>
</IfModule>' >> /etc/apache2/apache2.conf

# Kiểm tra cấu hình Apache
apachectl configtest
if [ $? -ne 0 ]; then
    echo "Cấu hình Apache gặp lỗi. Kiểm tra lại cấu hình."
    exit 1
fi

# Khởi động lại Apache để áp dụng cấu hình mới
systemctl restart apache2
if [ $? -ne 0 ]; then
    echo "Khởi động lại Apache thất bại. Kiểm tra lại dịch vụ."
    exit 1
fi

