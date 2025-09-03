# Apache, Tomcat 모니터링 및 튜닝

## 1. Apache 모니터링(server-status) 설정

- WEB서버에서 apacheServer11의 설정 변경을 진행합니다.

```bash
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

## 2. Tomcat 모니터링(probe) 설정

- WAS서버에서 모니터링 구성을 확인합니다.

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

## 3. Apache, Tomcat 모니터링 스크립트 활용

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
mkdir /home/webwas/shl
mv mon /home/webwas/shl/mon 
cd /home/webwas/shl/mon

# 점검 스크립트 수행
./check_web.sh
```

## 4. Apache 튜닝 설정 확인

```bash
# ---------------------
# WEB 서버
# ---------------------
# thread 설정 - conf/extra/httpd-mpm.conf

# 로그 포멧 설정 - conf/httpd.conf

# worker timeout - conf/extra/workers.properties
```

## 5. Tomcat 튜닝 설정 확인

```bash
# ---------------------
# WAS 서버
# ---------------------
# jvm 옵션 - shl/tomcat.env

# thread 설정 - shl/tomcat.env

# datasource 설정 - conf/Catalina/localhost/{CONTEXT}.xml
```