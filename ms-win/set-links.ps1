# 运行前必须安装pscx
# 在本文件的上级目录，即~/下运行本文件
# su .emacs.d\set-links.ps1
# 太麻烦，还要装pscx，建议用Symlink Creator

set-psdebug -strict



#$emacs_dir = "..\emacs-23.3"
#$emacs_dir = "..\emacs-23.4"
#$emacs_dir = "..\emacs-24.0.94"

#$emacs_dir = "..\myemacs-23.3"
#$emacs_dir = "..\myemacs-23.4"
#$emacs_dir = "..\myemacs-24.0.94"
#$emacs_dir = "..\myemacs-24.0.95"
#$emacs_dir = "..\myemacs-24.0.96"
#$emacs_dir = "..\myemacs-24.0.96-smart-ime-mingw"
#$emacs_dir = "..\myemacs-24.0.96-smart-ime-msvc"
#$emacs_dir = "..\myemacs-24.1-smart-ime-mingw"
#$emacs_dir = "..\myemacs-24.2-smart-ime-mingw"
$emacs_dir = "..\myemacs-24.3-smart-ime-mingw"

$only_remove = "false"
if ($args.length -ge 1) {
    if ($args[0] -eq "remove") {
        $only_remove = "true"
    }
}


function path-exist($path)
{
    $found = test-path $path
    $found
}

function make-link($link_path, $target_path)
{
    if (path-exist($link_path) -eq "true") {
        Remove-ReparsePoint $link_path
    }

    if ($only_remove -eq "true") {
        return
    }

    if (path-exist($target_path) -eq "true") {
        new-symlink $link_path $target_path
    }
}

################ emacs ################
make-link "..\emacs" $emacs_dir

