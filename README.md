# ryans-dev-prompt
Custom prompt which prints the current working directory as well as some git info when in a repository. Implemented for bash and zsh. 



To enable run the script from your bash/zsh profile. For example, if you have the file in ~/repos/ryans-dev-prompt/

## zsh

... add the following to your .zshrc or .zprofile
 
```
if [ -f ~/repos/ryans-dev-prompt/ryans-dev-prompt-bash.sh ]; then
  source ~/repos/util/ryans-dev-prompt/ryans-dev-prompt-bash.sh
fi
```

## bash
... add the following to your .bash_profile
```
if [ -f ~/repos/ryans-dev-prompt/ryans-dev-prompt-bash.sh ]; then
  source ~/repos/util/ryans-dev-prompt/ryans-dev-prompt-bash.sh
fi
```
