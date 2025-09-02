#/home/ec2-user/docker/tomcat-10.1.28-jre17
FROM tomcat:10.1.28-jre17

# Set timezone(UTC -> KST)
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Delete Default apps 
RUN rm -Rf /usr/local/tomcat/webapps/*

# Change server.xml(MW Std.)
RUN mv /usr/local/tomcat/conf/server.xml  /usr/local/tomcat/conf/server.xml.ori
RUN mv /usr/local/tomcat/conf/context.xml /usr/local/tomcat/conf/context.xml.ori
COPY   ./conf/server.xml                  /usr/local/tomcat/conf/
COPY   ./conf/context.xml                 /usr/local/tomcat/conf/

# Set probe mon
RUN mv /usr/local/tomcat/conf/tomcat-users.xml /usr/local/tomcat/conf/tomcat-users.xml.ori
COPY   ./conf/tomcat-users.xml                 /usr/local/tomcat/conf/
COPY   ./webapps/probe.war                     /usr/local/tomcat/webapps/

# Set Datadog Agent ( Edit SKT-SVC-ecs-tomcat1 to SKT Service Name )
#RUN mkdir   /usr/local/tomcat/datadog
#RUN wget -O /usr/local/tomcat/datadog/dd-java-agent.jar 'https://dtdg.co/latest-java-tracer'
#ENV JAVA_OPTS="$DATADOG_OPTS"

# Copy apps ( init app, replace by Application DOCROOT at CI/CD )
#ADD ./app/ROOT.tar /usr/local/tomcat/webapps/

# JVM Option - HeapMemory (OLD Size)
ENV JAVA_OPTS="-Xms1024m -Xmx1024m"
# JVM Option - HeapMemory (YOUNG Size)
ENV JAVA_OPTS="$JAVA_OPTS -XX:NewSize=384m -XX:MaxNewSize=384m"
# JVM Option - HeapMemory (PERM Size)
ENV JAVA_OPTS="$JAVA_OPTS -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=256m"
# JVM Option - GC Option  (Parallel OLD GC)
ENV JAVA_OPTS="$JAVA_OPTS -XX:SurvivorRatio=8 -XX:ParallelGCThreads=4 -XX:+DisableExplicitGC -XX:+UseParallelGC -XX:-UseAdaptiveSizePolicy"
# JVM Option - GC Log Option
ENV JAVA_OPTS="$JAVA_OPTS -Xlog:gc*,gc+heap=trace:file=/usr/local/tomcat/logs/gc.log:time"
# JVM Option - HeapDump Option
ENV JAVA_OPTS="$JAVA_OPTS -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/usr/local/tomcat/logs"
# JVM Option - Java Compiler Optimize, 
ENV JAVA_OPTS="$JAVA_OPTS -XX:+DoEscapeAnalysis -XX:+UseCompressedOops"
# JVM Option - AWT headless
ENV JAVA_OPTS="$JAVA_OPTS -Djava.awt.headless=true"
# JVM Option - Using only IPv4
ENV JAVA_OPTS="$JAVA_OPTS -Djava.net.preferIPv4Stack=true"
# JVM Option - URI Encoding
ENV JAVA_OPTS="$JAVA_OPTS -Dtomcat.connector.URIEncoding=UTF-8"
# JVM Option - POST Message Size
ENV JAVA_OPTS="$JAVA_OPTS -Dtomcat.connector.maxPostSize=2097152"
# JVM Option - Thread Pool Min/Max Size
ENV JAVA_OPTS="$JAVA_OPTS -Dtomcat.connector.maxThreads=200"
ENV JAVA_OPTS="$JAVA_OPTS -Dtomcat.connector.minSpareThreads=200"

# Port Definition
ENV JAVA_OPTS="$JAVA_OPTS -Dtomcat.port.http=80"
ENV JAVA_OPTS="$JAVA_OPTS -Dtomcat.port.https=443"
ENV JAVA_OPTS="$JAVA_OPTS -Dtomcat.port.shutdown=8105"
ENV JAVA_OPTS="$JAVA_OPTS -Dtomcat.port.ajp=8109"

# Run Tomcat
WORKDIR /usr/local/tomcat/bin

CMD ["./catalina.sh", "run"]
# CMD ["tail", "-f", "/dev/null"]

