# Apache, Tomcat 구성 실습 (2025년 9월 10일)

## 1. Apache 설치

```bash
# ---------------------
# [실습 환경] - WEB 서버
# ---------------------
# 실습 폴더 이동
cd /home/webwas/education

# ---------------------
# 1. 설치 파일 다운로드
# ---------------------
# Apache 설치 파일 다운로드 (생략)
# - https://httpd.apache.org 접속하여 다운로드
wget https://archive.apache.org/dist/httpd/httpd-2.4.64.tar.gz

# Apache 설치 파일 압축 해제
tar xvf httpd-2.4.64.tar.gz

# Apache 압축 해제 경로로 이동 및 파일 확인
cd /home/webwas/education/httpd-2.4.64

# srclib 폴더로 이동
cd /home/webwas/education/httpd-2.4.64/srclib
# apr package 다운로드
wget https://dlcdn.apache.org//apr/apr-1.7.6.tar.gz
wget https://dlcdn.apache.org//apr/apr-util-1.6.3.tar.gz
wget https://dlcdn.apache.org//apr/apr-iconv-1.2.2.tar.gz
# apr package 압축해제 및 폴더명 변경
tar xvf apr-1.7.6.tar.gz;       mv apr-1.7.6       apr
tar xvf apr-util-1.6.3.tar.gz;  mv apr-util-1.6.3  apr-util
tar xvf apr-iconv-1.2.2.tar.gz; mv apr-iconv-1.2.2 apr-iconv

# ---------------------
# 2. Apache 설치(컴파일)을 위한 OS 패키지 확인
# ---------------------
# gcc
rpm -qa | grep "^gcc-[0-9]"
# perl
rpm -qa | grep "^perl-[0-9]"
# pcre / pcre-devel
rpm -qa | egrep "^pcre-[0-9]|pcre-devel-[0-9]"
# openssl / openssl-devel
rpm -qa | egrep "openssl-[0-9]|openssl-devel-[0-9]"
# expat / expat-devel
rpm -qa | egrep "expat-[0-9]|expat-devel-[0-9]"
# http2 / http2-devel
rpm -qa | grep -E "^nghttp2-[0-9]"
rpm -qa | grep -E "^libnghttp2-devel-[0-9]"

# ---------------------
# 3. Apache 설치(컴파일)
# ---------------------
# configure - 설정 및 환경 점검 => Makefile 생성
cd /home/webwas/education/httpd-2.4.64
./configure \
  --prefix=/software/apache \
  --enable-mods-shared=all \
  --with-mpm=event \
  --with-included-apr \
  --enable-ssl \
  --enable-http2

# make - Makefile을 기반으로 gcc 컴파일러 실행(컴파일)
make

# make install - 컴파일된 파일을 설치 경로(prefix)에 이동(설치)
make install

# Apache 설치 확인
cd /software/apache/bin
./httpd -V


# ---------------------
# 4. Tomcat Connector(AJP Module) 설치
# ---------------------
# 다운로드
# - https://tomcat.apache.org/download-connectors.cgi
wget https://dlcdn.apache.org/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.50-src.tar.gz

# 설치 파일 압축 해제 및 폴더 이동
tar xvf tomcat-connectors-1.2.50-src.tar.gz
cd /home/webwas/education/tomcat-connectors-1.2.50-src/native

# 설치 - apache 설치 정보 확인을 위한 apxs(Apache eXtenSion tool) 경로 추가
./configure --with-apxs=/software/apache/bin/apxs
make
make install

# 설치된 모듈 확인
ls -lart /software/apache/modules
...
# mod_jk.so 생성 확인

# 필수 파일 복사 (참고)
#cd tomcat-connectors-1.2.50-src/conf
#cp httpd-jk.conf           ${APACHE_HOME}/conf/extra
#cp uriworkermap.properties ${APACHE_HOME}/conf/extra
#cp workers.properties      ${APACHE_HOME}/conf/extra


# ---------------------
# 5. 보안 취약점 조치(최소)
# ---------------------
# 설치 경로 권한 수정
chmod 750 /software/apache
chmod 700 /software/apache/*
chmod 750 /software/apache/logs

# 운영에 불필요한 디렉토리 삭제
rm -rf /software/apache/manual
rm -rf /software/apache/cgi-bin
rm -rf /software/apache/conf      # native하게 사용할 경우 삭제 대상에서 제외

# ---------------------
# 6. (선택) setuid, setgid 설정
# ---------------------
# httpd 파일 권한 변경(setuid, setgid : 실행될때 해당 uid, gid로 실행)
cd /software/apache/bin
sudo chown root:webwas httpd
sudo chmod 6750 httpd

# ---------------------
# 6. Apache Teplate 폴더 복사
# --------------------- 
cd /home/webwas/education
cp -Rp apache-servers /software/apache/servers
```

## 2. Apache 인스턴스 구성

### 2.1. apacheServer11

```bash
# ---------------------
# WEB 서버
# ---------------------
# 인스턴스 폴더(servers)로 이동
cd /software/apache/servers

# create_server.sh 파일 확인
vim create_server.sh

# 'apacheServer11' 인스턴스 생성
./create_server.sh apacheServer11

# 인스턴스 폴더 생성 확인
ls -l 

# 인스턴스 설정 폴더 이동
cd /software/apache/servers/apacheServer11/conf
ls -l 

# httpd.conf 파일 수정
cp /home/webwas/education/sample-app/httpd.conf ./httpd.conf
# (수정:155) DocumentRoot "/home/webwas/education/sample-app/apache"
# (수정:156) <Directory "/home/webwas/education/sample-app/apache">

# 인스턴스 실행
cd /software/apache/servers/apacheServer11/shl
./start.sh

# 웹 페이지 접속 확인
# web서버 IP 확인
# 웹 브라우저에서 http://IP 로 접속
```

## 3. Tomcat 설치

```bash
# ---------------------
# WAS 서버
# ---------------------
# 실습 폴더 이동
cd /home/webwas/education

# Tomcat 템플릿 파일 압축 해제
tar xvf apache-tomcat-10.1.25-template.20240807.tar

# 'tomcat' 폴더를 /software 하위로 이동
mv tomcat /software/tomcat

# Tomcat 설치 확인
cd /software/tomcat/bin
./version.sh

# JDBC 드라이버 복사 (app 테스트용)
cd /software/tomcat/jdbc
ls -l
cp mysql-connector-j-8.0.33.jar ../lib/mysql-connector-j-8.0.33.jar
```

## 4. Tomcat 인스턴스 구성

### 4.1. tomcatServer11

```bash
# ---------------------
# WAS 서버
# ---------------------
# 인스턴스 폴더(servers)로 이동
cd /software/tomcat/servers

# create_server.sh 파일 확인
vim create_server.sh

# 'tomcatServer11' 인스턴스 생성
./create_server.sh tomcatServer11

# 인스턴스 폴더 생성 확인
ls -l 

# 인스턴스 설정 폴더 이동
cd /software/tomcat/servers/tomcatServer11/conf
ls -l 

# server.xml을 cluster설정 파일로 변경(연동 테스트용)
cp server.xml.cluster server.xml

# context 설정 파일(ROOT.xml) 수정
cd /software/tomcat/servers/tomcatServer11/conf/Catalina/localhost
cp /home/webwas/education/sample-app/ROOT.xml ./ROOT.xml
# (수정) docBase=/home/webwas/education/sample-app/tomcat
# (수정) datasource 설정 추가(MYSQL)

# 인스턴스 shl 폴더로 이동
cd /software/tomcat/servers/tomcatServer11/shl
ls -l

# tomcat.env 기본 설정 파일 확인
vi tomcat.env

# 인스턴스 실행
cd /software/tomcat/servers/tomcatServer11/shl
./start.sh

# 웹 페이지 접속 확인
# was서버 IP 확인
# 웹 브라우저에서 http://IP:8180/index.html 로 접속
# 웹 브라우저에서 http://IP:8180/index.jsp 로 접속
```

### 4.2. tomcatServer12

```bash
# ---------------------
# WAS 서버
# ---------------------
# 인스턴스 폴더(servers)로 이동
cd /software/tomcat/servers

# create_server.sh 파일 확인
vim create_server.sh

# 'tomcatServer12' 인스턴스 생성
./create_server.sh tomcatServer12

# 인스턴스 폴더 생성 확인
ls -l 

# 인스턴스 설정 폴더 이동
cd /software/tomcat/servers/tomcatServer12/conf
ls -l 

# server.xml을 cluster설정 파일로 변경(연동 테스트용)
cp server.xml.cluster server.xml

# context 설정 파일(ROOT.xml) 수정
cd /software/tomcat/servers/tomcatServer12/conf/Catalina/localhost
cp /home/webwas/education/sample-app/ROOT.xml ./ROOT.xml
# (수정) docBase=/home/webwas/education/sample-app/tomcat
# (수정) datasource 설정 추가(MYSQL)

# 인스턴스 shl 폴더로 이동
cd /software/tomcat/servers/tomcatServer12/shl
ls -l

# tomcat.env 기본 설정 파일 수정
cp /home/webwas/education/sample-app/tomcat.env ./tomcat.env
# Port 정보 수정
# tomcat.port.shutdown=8205
# tomcat.port.http=8280
# tomcat.port.https=8543
# tomcat.port.ajp=8209
# tomcat.cluster.receiver.port=5002

# 인스턴스 실행
cd /software/tomcat/servers/tomcatServer12/shl
./start.sh

# 웹 페이지 접속 확인
# was서버 IP 확인
# 웹 브라우저에서 http://IP:8280/index.html 로 접속
# 웹 브라우저에서 http://IP:8280/index.jsp 로 접속
```

## 5. Apache, Tomcat 연동 설정

```bash
# ---------------------
# WEB 서버
# ---------------------
# extra 설정 폴더로 이동
cd /software/apache/servers/apacheServer11/conf/extra

# httpd-jk.conf 파일 확인
vim httpd-jk.conf

# uriworkermap.properties 파일 확인
vim uriworkermap.properties

# workers.properties 파일 수정
cp /home/webwas/education/sample-app/workers.properties ./workers.properties
# CON_NAME_Must_Change1 -> tomcatServer11
# CON_NAME_Must_Change2 -> tomcatServer12
vi workers.properties
# worker.tomcatServer1#.host=localhost -> 172.31.1xx.2

# Apache 인스턴스 재기동
cd /software/apache/servers/apacheServer11/shl
./stop.sh
./start.sh

# 연동 테스트
# web서버 IP 확인
# 웹 브라우저에서 http://IP/index.html 로 접속
# 웹 브라우저에서 http://IP/index.jsp 로 접속
```

## 6. Apache 모니터링(server-status) 설정

```bash
# ---------------------
# WEB 서버
# ---------------------
# Apache info 설정 파일 확인
cd /software/apache/servers/apacheServer11/conf/extra
vi httpd-info.conf

# server-status 확인
# web서버 IP 확인
# 웹 브라우저에서 http://IP/server-status 로 접속

# server-info 확인
# web서버 IP 확인
# 웹 브라우저에서 http://IP/server-info 로 접속
```

## 7. Tomcat 모니터링(probe) 설정

```bash
# ---------------------
# WAS 서버
# ---------------------
# Tomcat webapps 경로 확인
cd /software/tomcat/servers/tomcatServer11/webapps
ls -l 

# probe 페이지 확인
# was서버 IP 확인
# 웹 브라우저에서 http://IP:8180/probe 로 접속
# id : probeuser
# pw : ProbeUser1!
```

## 8. Apache, Tomcat 모니터링 스크립트 활용

```bash
# ---------------------
# WEB, WAS 서버
# ---------------------
# 실습 폴더 이동
cd /home/webwas/education

# mon.tar 파일 확인 및 압축 해제
ls -l mon.tar
tar xvf mon.tar

# mon 디렉토리를 /home/webwas/shl/mon 으로 이동
mv mon /home/webwas/shl/mon 
cd /home/webwas/shl/mon

# 점검 스크립트 수행
./check_web.sh
```

## 9. Apache 튜닝 설정 확인

```bash
# ---------------------
# WEB 서버
# ---------------------
# thread 설정 - conf/extra/httpd-mpm.conf

# 로그 포멧 설정 - conf/httpd.conf

# worker timeout - conf/extra/workers.properties
```

## 10. Tomcat 튜닝 설정 확인

```bash
# ---------------------
# WAS 서버
# ---------------------
# jvm 옵션 - shl/tomcat.env

# thread 설정 - shl/tomcat.env

# datasource 설정 - conf/Catalina/localhost/{CONTEXT}.xml
```

## 11. Apache 업그레이드

```bash
# ---------------------
# WEB 서버
# ---------------------
# 실행중인 인스턴스 down
cd /software/apache/servers/apacheServer11/shl; ./stop.sh

# 실습 폴더 이동
cd /home/webwas/education

# 업그레이드 버전 파일 압축 해제
tar xvf httpd-2.4.62.tar.gz

# 신규 버전 파일 이동
cd httpd-2.4.62

# 이전 설치 옵션(configure) 파일 복사
cp /software/apache/build/config.nice /home/webwas/education/httpd-2.4.62/config.nice

# 신규 버전 폴더 이동 후 업데이트(신규 버전 빌드)
cd /home/webwas/education/httpd-2.4.62
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

## 12. Tomcat 업그레이드

```bash
# ---------------------
# WAS 서버
# ---------------------
# 실행중인 인스턴스 down
cd /software/tomcat/servers/tomcatServer11/shl; ./stop.sh
cd /software/tomcat/servers/tomcatServer12/shl; ./stop.sh

# 기존 버전 폴더 백업
cd /software/tomcat
cp -Rp bin bin.backup
cp -Rp lib lib.backup

# 실습 폴더 이동
cd /home/webwas/education

# 업그레이드 버전 파일 압축 해제
tar xvf apache-tomcat-10.1.28.tar.gz

# 신규 버전 폴더 이동
cd apache-tomcat-10.1.28

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
