#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
#define PORT 8080
#define BLOCK_SIZE 20
#define MAX_LINE 100
int main()
{
	int sockfd,connfd,clilen,i;
	struct sockaddr_in serv_addr, cli;
	char buff[BLOCK_SIZE], filename[MAX_LINE];

	sockfd = socket(AF_INET, SOCK_STREAM,0);
	if(sockfd < 0)
	{
		printf("Socket creation error");
		exit(1);
	}
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_addr.s_addr = INADDR_ANY;
	serv_addr.sin_port = htons(PORT);
	
	if(bind(sockfd,(struct sockaddr *)&serv_addr,sizeof(serv_addr))<0)
	{
		printf("Bind failed");
		exit(1);
	}
	printf("Server is running...\n");
    
	listen(sockfd,5);
	int bytes_rec,filefd;
	while(1){
		char code;
		clilen = sizeof(cli);
		connfd = accept(sockfd,(struct sockaddr *)&serv_addr,&clilen);
		if(connfd<0)
		{
			printf("Error in accepting the client");
			exit(1);
		}
		printf("New client is connected..\n");
		bzero(filename,MAX_LINE);
		int flag = 0;		
		while(!flag){
			bzero(buff,BLOCK_SIZE);
			
			bytes_rec = recv(connfd,buff,BLOCK_SIZE-1,0);
			
			
			strcat(filename,buff);
			
			for(i=0;i<BLOCK_SIZE-1;i++)
			{
				if(buff[i]=='\0')
				{
					flag = 1;
					break;
				}
			}
		}
		
		
		filefd = open(filename,O_RDONLY);
		
		if(filefd<0){			
			code = 'E';
			send(connfd,&code,sizeof(code),0);
			close(connfd);
		}
		
		else{
			
			code = 'L';
			send(connfd,&code,sizeof(code),0);
		
			struct stat st;
			fstat(filefd,&st);	
			
			int f_size = (int)st.st_size;			
			char fsize[10];
			sprintf(fsize,"%d",f_size);
			
			send(connfd,fsize,sizeof(fsize),0);
			int nbytes_read;
			while(1){
				
				nbytes_read = read(filefd,buff,BLOCK_SIZE);
				
				
				if(nbytes_read == 0)
					break;
				
				send(connfd,buff,BLOCK_SIZE,0);
				
				bzero(buff,BLOCK_SIZE);
			}
			
			close(filefd);
			close(connfd);
			
		}
	}
}