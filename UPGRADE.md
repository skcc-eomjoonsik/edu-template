# Apache, Tomcat 업그레이드

## 1. Apache 업그레이드

```bash
# 실행중인 인스턴스 down
cd /software/apache/servers/apacheServer11/shl; ./stop.sh

# 실습 폴더 이동
cd /home/webwas/education

# 최신 버전 다운로드 및 압축 해제
wget https://dlcdn.apache.org/httpd/httpd-2.4.65.tar.gz
tar xvf httpd-2.4.65.tar.gz 
cd httpd-2.4.65/srclib

# APR package 다운로드
wget https://dlcdn.apache.org//apr/apr-1.7.6.tar.gz
wget https://dlcdn.apache.org//apr/apr-util-1.6.3.tar.gz
wget https://dlcdn.apache.org//apr/apr-iconv-1.2.2.tar.gz

# apr package 압축해제 및 폴더명 변경
tar xvf apr-1.7.6.tar.gz;       mv apr-1.7.6       apr
tar xvf apr-util-1.6.3.tar.gz;  mv apr-util-1.6.3  apr-util
tar xvf apr-iconv-1.2.2.tar.gz; mv apr-iconv-1.2.2 apr-iconv

# 이전 설치 옵션(configure) 파일 및 srclib 폴더 복사
cp /software/apache/build/config.nice /home/webwas/education/httpd-2.4.65/config.nice

# 신규 버전 폴더 이동 후 업데이트(신규 버전 빌드)
cd /home/webwas/education/httpd-2.4.65
./config.nice
make
make install

# Apache 설치 확인
cd /software/apache/bin
./httpd -V

# httpd 파일 권한 변경(setuid, setgid : 실행될때 해당 uid, gid로 실행)
cd /software/apache/bin
sudo chown root:webwas httpd
sudo chmod 6750 httpd

# 인스턴스 startup
cd /software/apache/servers/apacheServer11/shl; ./start.sh
```

## 2. Tomcat 업그레이드

```bash
# 실행중인 인스턴스 down
cd /software/tomcat/servers/tomcatServer11/shl; ./stop.sh
cd /software/tomcat/servers/tomcatServer12/shl; ./stop.sh

# 기존 버전 폴더 백업
cd /software/tomcat
cp -Rp bin bin.backup
cp -Rp lib lib.backup

# 실습 폴더 이동
cd /home/webwas/education

# 업그레이드 버전 파일 다운로드 및 압축 해제
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.44/bin/apache-tomcat-10.1.44.tar.gz
tar xvf apache-tomcat-10.1.44.tar.gz

# 신규 버전 폴더 이동
cd apache-tomcat-10.1.44

# bin, lib 디렉토리 복사(기존 파일 덮어쓰기)
cp -Rp bin /software/tomcat/
cp -Rp lib /software/tomcat/

# Tomcat 업그레이드 버전 확인
cd /software/tomcat/bin
./version.sh

# 인스턴스 startup
cd /software/tomcat/servers/tomcatServer11/shl; ./start.sh
cd /software/tomcat/servers/tomcatServer12/shl; ./start.sh
```
