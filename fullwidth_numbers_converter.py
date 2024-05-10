import os
import sys
import re

# 获取命令行参数，如果未指定则默认为当前目录
directory = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()

# 遍历目录中的文件
for filename in os.listdir(directory):
    # 匹配文件名中含有全角数字的
    match = re.findall(r"[\uFF10-\uFF19]", filename)

    # 如果匹配到，则将全角数字转换成半角数字
    if match:
        new_filename = filename
        for num in match:
            new_filename = new_filename.replace(num, str(int(num)))
        print(f"new filename {new_filename}!")

        # 重命名文件
        os.rename(
            os.path.join(directory, filename), os.path.join(directory, new_filename)
        )
