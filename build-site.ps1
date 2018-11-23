if (-Not (Test-Path env:JEKYLL_ENV))
{
    Set-Item -path env:JEKYLL_ENV -value "staging"
}

Set-Item -path env:JEKYLL_CONFIG -value ("_config.yml,_config-"+$env:JEKYLL_ENV+".yml")

$pwd = (Get-Location)

# If GEM_HOME is declared, see if it is in the current directory. If not, we need
# to volume-mount it and change the variable value. If it isn't declared, create
# the default gems directory. Similarly, if DEST_DIR isn't declared, create the
# default dest directory.
$params = 'run', '--rm', '-it',
          '-e', 'JEKYLL_ACTION=build',
          '-e', 'JEKYLL_CONFIG',
          '-e', 'JEKYLL_ENV',
          '-e', 'SOURCE_DIR',
          '-e', 'DEST_DIR'
if (Test-Path env:GEM_HOME) {
    $gem_home = $env:GEM_HOME
    $parent = (Split-Path -parent $gem_home)
    if ((Join-Path $parent '') -ne $pwd)
    {
        $params += '-e', "GEM_HOME=""/gems/$(Split-Path -Leaf $gem_home)""", '-v', "$($parent -replace '\\', '/'):/gems"
    }
    else {
        $params += '-e', 'GEM_HOME'
    }
}
else {
    New-Item -ItemType Directory -Force -Path ${pwd}/.gems
}
if (!Test-Path env:DEST_DIR) {
    New-Item -ItemType Directory -Force -Path ${pwd}/dest_dir
}
$params += '-v', "${pwd}:/srv", 'linaroits/jekyllsitebuild', 'build-site.sh'
& docker @params
