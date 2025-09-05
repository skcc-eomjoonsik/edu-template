# Apache 설치 및 인스턴스(템플릿) 구성

## 실습 진행 환경

- 실습용 서버(EC2) 2대 중 WEB서버에서 진행합니다.

## 실습 1 - Apache 설치

### 1. 실습 폴더로 이동

```bash
cd /home/webwas/education
```

### 2. Apache 설치 파일 다운로드

- Apache [공식 페이지](https://httpd.apache.org)에 접속하여 다운로드  
  (업그레이드 실습을 진행할거라 2.4.64 버전을 다운로드하여 진행합니다.)

```bash
# 2.4.64 버전 다운로드
wget https://archive.apache.org/dist/httpd/httpd-2.4.64.tar.gz

# 설치 파일 압축 해제
tar xvf httpd-2.4.64.tar.gz

# Apache 압축 해제 경로 하위의 srclib 폴더로 이동
cd /home/webwas/education/httpd-2.4.64/srclib

# APR package 다운로드
wget https://dlcdn.apache.org//apr/apr-1.7.6.tar.gz
wget https://dlcdn.apache.org//apr/apr-util-1.6.3.tar.gz
wget https://dlcdn.apache.org//apr/apr-iconv-1.2.2.tar.gz

# apr package 압축해제 및 폴더명 변경
tar xvf apr-1.7.6.tar.gz;       mv apr-1.7.6       apr
tar xvf apr-util-1.6.3.tar.gz;  mv apr-util-1.6.3  apr-util
tar xvf apr-iconv-1.2.2.tar.gz; mv apr-iconv-1.2.2 apr-iconv
```

### 3. Apache 설치(컴파일)을 위한 OS 패키지 확인

```bash
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
```

### 4. Apache 설치(컴파일)

```bash
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
```

### 5. Tomcat Connector(mod_jk Module) 설치

- Connector는 Tomcat [공식 페이지](https://tomcat.apache.org)에서 제공합니다.

```bash
# Connector 설치 파일 다운로드
cd /home/webwas/education
wget https://dlcdn.apache.org/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.50-src.tar.gz

# 설치 파일 압축 해제 및 폴더 이동
tar xvf tomcat-connectors-1.2.50-src.tar.gz
cd /home/webwas/education/tomcat-connectors-1.2.50-src/native

# 설치 - apache 설치 정보 확인을 위한 apxs(Apache eXtenSion tool) 경로 추가
./configure --with-apxs=/software/apache/bin/apxs
make
make install

# 설치된 모듈 확인
# ls 명령을 수행하면 mod_jk.so 파일이 생성되어 있습니다.
ls -lart /software/apache/modules

# (참고) Tomcat 연동을 위한 설정 파일 복사
#cd /home/webwas/education/tomcat-connectors-1.2.50-src/conf
#cp httpd-jk.conf           ${APACHE_HOME}/conf/extra
#cp uriworkermap.properties ${APACHE_HOME}/conf/extra
#cp workers.properties      ${APACHE_HOME}/conf/extra
```

### 6. 기본 보안 취약점 조치

```bash
# 설치 경로 권한 수정
chmod 750 /software/apache /software/apache/logs
chmod 700 /software/apache/{bin,build,conf,error,htdocs,icons,include,lib,modules}

# 실행 파일 권한 수정
chmod 700 /software/apache/bin/*
chmod 600 /software/apache/bin/envvars*

# 운영에 불필요한 디렉토리 삭제
rm -rf /software/apache/{manual,man} # Manual page (manual : 웹소스, man : man httpd용도)
rm -rf /software/apache/cgi-bin      # CGI(Common Gateway Interface) 스크립트 사용시 삭제 대상에서 제외
rm -rf /software/apache/conf         # native하게 사용할 경우 삭제 대상에서 제외
```

### 7. (선택) setuid, setgid 설정

- Linux 시스템에서 1024보다 작은 Port(ex. 80, 443)는 Linux 보안 정책상 root 계정으로만 오픈할 수 있습니다.
- 회사의 보안 정책상 Apache(httpd)와 같은 일반 Software를 root 계정으로 실행하는 것을 허용하지 않습니다.
- 80, 443 Port로 서비스를 해야 할 경우 일반 운영 계정(실습 환경에서는 webwas 계정)으로 실행할 수 있도록 권한 조정을 할 수 있는데 `setuid`와 `setgid` 비트를 적용하면 됩니다.
  - setuid : 실행시 파일 소유자(root)의 권한으로 동작
  - setgid : 실행시 파일 그룹 권한으로 동작

```bash
cd /software/apache/bin
sudo chown root:webwas httpd
# 실행은 webwas 계정으로 하고, 프로세스는 root 계정으로 실행되어 80, 443 Port 오픈(Binding)이 가능
sudo chmod 6750 httpd
```

### 8. Apache Teplate 폴더 복사

```bash
cd /home/webwas/education
cp -Rp template-apache/servers /software/apache/servers
cp -Rp template-apache/shl     /software/apache/shl
```

## 실습 2 - Apache 인스턴스 구성

### 1. apacheServer11 인스턴스 구성

- 인스턴스명 : apacheServer11
- 서비스 Port : 80(HTTP)

```bash
# Apache 인스턴스 관리 폴더(servers)로 이동
cd /software/apache/servers

# create_server.sh 파일 확인
vim create_server.sh

# 'apacheServer11' 인스턴스 생성
./create_server.sh apacheServer11

# 인스턴스 폴더 생성 확인
ls -l 

# 인스턴스 설정 폴더 이동
cd /software/apache/servers/apacheServer11/conf

# httpd.conf 파일 수정 - Document Root 변경
cp /home/webwas/education/sample-app/httpd.conf ./httpd.conf
# (수정:155) DocumentRoot "/home/webwas/education/sample-app/apache"
# (수정:156) <Directory "/home/webwas/education/sample-app/apache">

# 인스턴스 실행
cd /software/apache/servers/apacheServer11/shl
./start.sh
```

### 2. 웹 페이지 접속 확인

- 개인별 WEB 서버 IP를 확인하여 웹 브라우저에서 http://IP 로 접속해보세요.
