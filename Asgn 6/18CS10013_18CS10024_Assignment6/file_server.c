#include <stdio.h> 
#include <netdb.h> 
#include <netinet/in.h> 
#include <stdlib.h> 
#include <string.h> 
#include <sys/socket.h> 
#include <sys/types.h> 
#include <unistd.h>
#include <fcntl.h>
#include <arpa/inet.h>

#define MAXLINE 100
#define PORT 8080 

int main() 
{ 
	int sockfd, connfd, len; 
	struct sockaddr_in servaddr, cli; 

	sockfd = socket(AF_INET, SOCK_STREAM, 0); 

	if (sockfd == -1) { 
		printf("Socket not created...\nExiting..."); 
		exit(0); 
	} 
	else
		printf("Socket created..\n"); 
	
	bzero(&servaddr, sizeof(servaddr)); 

	servaddr.sin_family = AF_INET; 
	servaddr.sin_addr.s_addr = htonl(INADDR_ANY); 
	servaddr.sin_port = htons(PORT); 

	
	if ((bind(sockfd, (struct sockaddr*)&servaddr, sizeof(servaddr))) != 0) { 
		printf("Socket binding failed...\n"); 
		exit(0); 
	} 
	else
		printf("Socket binded..\n"); 

	if ((listen(sockfd, 5)) != 0) { 
		printf("Listening failed...\n"); 
		exit(0); 
	} 
	else
		printf("Server is listening..\n"); 
	
	len = sizeof(cli); 

    while(1){	

		connfd = accept(sockfd, (struct sockaddr*)&cli, &len); 

		if (connfd < 0) { 
			printf("Connection rejected...\n"); 
			exit(0); 
		} 
		else
			printf("Connection accepted...\n");

	    char fname[MAXLINE];
		recv(connfd, fname, MAXLINE,0);

		int fd  = open(fname, O_RDONLY);
		
		if(fd == -1)
		{
			close(connfd);
			continue;
		}
		
		char buff[MAXLINE];
		
		int bytes =0;

		while((bytes = read(fd,buff,sizeof(buff)))> 0)
		{
		  send(connfd, buff, bytes,0);
		}

		close(connfd);
		close(fd);
	}

	close(sockfd); 
	return 0;
} 
