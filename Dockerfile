FROM alpine:3.8 as builder

LABEL maintainer="Masahiro Yamada <adamay909@gmail.com>"

WORKDIR /opt

RUN 	apk add \
	build-base \
	pkgconf \
	automake \
	autoconf \
	bsd-compat-headers \
	zlib-dev \
	gzip \
	git  \
	bash \
	curl-dev \
	fuse-dev \
	expat-dev 

RUN	git clone https://github.com/archiecobbs/s3backer.git

WORKDIR /opt/s3backer

RUN	./autogen.sh &&\
	./configure &&\
	make dist &&\ 
	./autogen.sh &&\
	./configure &&\
	make &&\
	cp s3backer /s3backer


FROM alpine:3.8
WORKDIR /
COPY --from=builder /s3backer /usr/bin/s3backer

RUN 	apk --no-cache add \
			fuse \
			curl \
			expat \
			zlib &&\
	mkdir /s3b 

		
ENTRYPOINT [ "/usr/bin/s3backer","-f" ]

CMD ["--help"]

	







