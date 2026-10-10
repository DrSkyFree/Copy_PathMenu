# CopyPathMenu
为右键添加“复制路径”，可选带引号与不带引号，也可清除右键中的“复制路径”

CopyPathMenu采用的是单文件自释放方案：

VBS 启动器作为内嵌载荷放在 bat 尾部的数据区（位于 exit /b 之后，cmd 永远不会执行它），每行以 #: 前缀标记
选择安装（1 或 2）时，bat 用 findstr + 延迟扩展自动把载荷提取、释放到 %LOCALAPPDATA%\CopyPathMenu\CopyPath.vbs，再写注册表
自愈能力：VBS 被删/被杀软清掉也不怕，重新运行一次安装即可重建
选择清除（3）时，会顺带删除已释放的 VBS 和目录，清理干净
您只需保管 CopyPathMenu.bat 这一个文件，复制到任何机器双击即用。
