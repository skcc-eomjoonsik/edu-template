# Tomcat 설치 및 인스턴스(템플릿) 구성

## 실습 진행 환경

- 실습용 서버(EC2) 2대 중 WAS서버에서 진행합니다.

## 실습 1 - Tomcat 설치

### 1. 실습 폴더로 이동

```bash
cd /home/webwas/education
```

### 2. Tomcat 설치 파일 다운로드 및 설치

- Tomcat [공식 페이지](https://tomcat.apache.org)에 접속하여 다운로드  
  (업그레이드 실습을 진행할거라 10.1.43 버전을 다운로드하여 진행합니다.)

```bash
# 10.1.43 버전 다운로드
wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.43/bin/apache-tomcat-10.1.43.tar.gz

# 설치 파일 압축 해제
# - apache-tomcat-10.1.43 폴더가 생성됩니다.
tar xvf apache-tomcat-10.1.43.tar.gz

# 압축 해제 폴더를 설치 경로로 이동
mv apache-tomcat-10.1.43 /software/tomcat

# Tomcat 설치 확인
cd /software/tomcat/bin
./version.sh
```

### 3. 기본 보안 취약점 조치

```bash
# 설치 경로 권한 수정
chmod 750 /software/tomcat

# 운영에 불필요한 디렉토리 삭제
rm -rf /software/tomcat/webapps/*
```

### 4. Tomcat 템플릿 폴더 복사

```bash
# 인프라 템플릿 구성 파일 복사
cd /home/webwas/education
cp -Rp template-tomcat/servers /software/tomcat/servers
cp -Rp template-tomcat/shl     /software/tomcat/shl
cp -Rp template-tomcat/jdbc    /software/tomcat/jdbc

chmod 700 /software/tomcat/servers
chmod 700 /software/tomcat/shl
chmod 750 /software/tomcat/jdbc

# [실습용] JDBC 드라이버 복사 (app 테스트용)
cd /software/tomcat/jdbc
cp mysql-connector-j-8.0.33.jar ../lib/mysql-connector-j-8.0.33.jar
```

## 실습 2 - Tomcat 인스턴스 구성

### 1. tomcatServer11 인스턴스 구성

- 인스턴스명 : tomcatServer11
- Port
  - 8180(HTTP)
  - 8109(AJP - Apache 연동)

```bash
# Tomcat 인스턴스 관리 폴더(servers)로 이동
cd /software/tomcat/servers

# create_server.sh 파일 확인
vim create_server.sh

# 'tomcatServer11' 인스턴스 생성
./create_server.sh tomcatServer11

# 인스턴스 폴더 생성 확인
ls -l 

# 인스턴스 설정 폴더 이동
cd /software/tomcat/servers/tomcatServer11/conf

# server.xml을 cluster설정 파일로 변경(세션 클러스터링 테스트용)
cp server.xml.cluster server.xml

# context 설정 파일(ROOT.xml) 수정
cd /software/tomcat/servers/tomcatServer11/conf/Catalina/localhost
cp /home/webwas/education/sample-app/ROOT.xml ./ROOT.xml
# (수정) docBase=/home/webwas/education/sample-app/tomcat
# (수정) datasource 설정 추가(MYSQL)

# 인스턴스 shl 폴더로 이동
cd /software/tomcat/servers/tomcatServer11/shl

# tomcat.env 기본 설정 파일 확인
vi tomcat.env
# Port 정보 확인(템플릿의 default port를 사용합니다.)
# tomcat.port.shutdown=8105
# tomcat.port.http=8180
# tomcat.port.https=8443
# tomcat.port.ajp=8309
# tomcat.cluster.receiver.port=5001

# 인스턴스 실행
cd /software/tomcat/servers/tomcatServer11/shl
./start.sh
```

### 2. 웹 페이지 접속 확인

- 개인별 WAS 서버 IP를 확인하여 웹 브라우저에서 다음 URL로 접속해보세요.
  - http://IP:8180/index.html
  - http://IP:8180/index.jsp

### 3. tomcatServer12 인스턴스 구성

- 인스턴스명 : tomcatServer12
- Port
  - 8280(HTTP)
  - 8209(AJP - Apache 연동)

```bash
# Tomcat 인스턴스 관리 폴더(servers)로 이동
cd /software/tomcat/servers

# create_server.sh 파일 확인
vim create_server.sh

# 'tomcatServer12' 인스턴스 생성
./create_server.sh tomcatServer12

# 인스턴스 폴더 생성 확인
ls -l 

# 인스턴스 설정 폴더 이동
cd /software/tomcat/servers/tomcatServer12/conf

# server.xml을 cluster설정 파일로 변경(세션 클러스터링 테스트용)
cp server.xml.cluster server.xml

# context 설정 파일(ROOT.xml) 수정
cd /software/tomcat/servers/tomcatServer12/conf/Catalina/localhost
cp /home/webwas/education/sample-app/ROOT.xml ./ROOT.xml
# (수정) docBase=/home/webwas/education/sample-app/tomcat
# (수정) datasource 설정 추가(MYSQL)

# 인스턴스 shl 폴더로 이동
cd /software/tomcat/servers/tomcatServer12/shl

# tomcat.env 기본 설정 파일 확인
vi tomcat.env
# Port 정보 수정
# tomcat.port.shutdown=8205
# tomcat.port.http=8280
# tomcat.port.https=8543
# tomcat.port.ajp=8209
# tomcat.cluster.receiver.port=5002

# 인스턴스 실행
cd /software/tomcat/servers/tomcatServer12/shl
./start.sh
```

### 4. 웹 페이지 접속 확인

- 개인별 WAS 서버 IP를 확인하여 웹 브라우저에서 다음 URL로 접속해보세요.
  - http://IP:8280/index.html
  - http://IP:8280/index.jsp

## Apache, Tomcat 연동 설정

Tomcat은 이미 준비가 되어 있습니다. Apache 설정을 변경해볼게요.

### Apache(apacheServer11 인스턴스) 설정 변경

```bash
# extra 설정 폴더로 이동
cd /software/apache/servers/apacheServer11/conf/extra

# httpd-jk.conf 파일 확인
vi httpd-jk.conf

# uriworkermap.properties 파일 확인
vi uriworkermap.properties

# workers.properties 파일 수정
cp /home/webwas/education/sample-app/workers.properties ./workers.properties
# CON_NAME_Must_Change1 -> tomcatServer11
# CON_NAME_Must_Change2 -> tomcatServer12
vi workers.properties
# worker의 IP 주소를 localhost -> WAS IP주소(172.31.1xx.2)로 바꿔주세요
# worker.tomcatServer1#.host=localhost -> 172.31.1xx.2

# Apache 인스턴스 재기동
cd /software/apache/servers/apacheServer11/shl
./stop.sh
./start.sh
```

### 5. 연동 확인

- 웹 브라우저에서 WEB서버 IP로 다음의 URL을 호출해보세요.
  - http://IP/index.html  (WEB서버가 처리)
  - http://IP/index.jsp   (WAS서버가 처리)
