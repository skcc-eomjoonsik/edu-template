# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs

#####################################
# Set up the prompt environment
#####################################
export PS1="[`whoami`@`hostname`:\$PWD]$ "
stty cs8 -istrip
stty erase ^H
set -o vi
export LANG=ko_KR.utf8

#####################################
# Set PATH
#####################################
export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto.x86_64
export PATH=$PATH:$HOME/bin:$HOME/shl:$HOME/shl/mon:.
export APACHE_HOME=/software/apache
export CATALINA_HOME=/software/tomcat
export APACHE_LOG=/log_data/apache
export TOMCAT_LOG=/log_data/tomcat
export PATH=${PATH}:${CATALINA_HOME}/shl:${APACHE_HOME}/shl

############################
# Alias
############################
alias ashl='cd ${APACHE_HOME}/shl;   ls -l'
alias tshl='cd ${CATALINA_HOME}/shl; ls -l'
alias alog='cd ${APACHE_LOG}; ls -l'
alias tlog='cd ${TOMCAT_LOG}; ls -l'
