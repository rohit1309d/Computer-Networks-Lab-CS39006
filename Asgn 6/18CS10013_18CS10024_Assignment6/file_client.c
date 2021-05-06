#include <netdb.h> 
#include <stdio.h> 
#include <stdlib.h> 
#include <string.h> 
#include <sys/socket.h> 
#include <unistd.h>
#include <netinet/in.h>
#include <fcntl.h>
#include <arpa/inet.h>

#define PORT 8080 
#define MAXLINE 100

int delimiter(char x)
{
	if( (x == '\n') || (x == '\t') ||  (x == ',') ||  (x == ' ') ||  (x == ':') || (x == '.') || (x == ';'))
		return 1;

	return 0;
}

int main() 
{ 
	int sockfd, connfd; 
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
	servaddr.sin_addr.s_addr = INADDR_ANY;
	servaddr.sin_port = htons(PORT); 

	
	if (connect(sockfd, (struct sockaddr*)&servaddr, sizeof(servaddr)) != 0) { 
		printf("Connection rejected...\n"); 
		exit(0); 
	} 
	else
		printf("Connection accepted...\n");


	char fname[MAXLINE];

	printf("Enter the file name : ");
	scanf("%[^\n]%*c", fname);

	send(sockfd,fname,strlen(fname)+1,0);

    char buff[MAXLINE];
	int bytes = recv(sockfd,buff,MAXLINE,0);
	if(bytes == 0)
	{
		printf("ERR 01: File Not Found\n");
		close(sockfd);
		return 0;
	}


	int tot_bytes=bytes;
	int tot_words = 0;


    int fd  = open("output.txt", O_WRONLY|O_CREAT|O_TRUNC,S_IRWXU);

    if(fd < 0)
    {
    	printf("File not created\n");
    	close(sockfd);
    	return 0;
    }

    int flag = 0 ;

    write(fd,buff,bytes);
     
	for(int i = 0;i < bytes;i++)
	{
		if(flag && delimiter(buff[i]))
		{
			tot_words++;
			flag=0;
		}

		else if( flag == 0 && delimiter(buff[i])==0)
		{
			flag = 1;
		}
	}

    while((bytes = recv(sockfd,buff,MAXLINE,0)) >0)
    {
		write(fd,buff,bytes);
		tot_bytes += bytes;

		for(int i=0;i<bytes;i++)
		{
			if(flag && delimiter(buff[i]))
			{
				tot_words++;

				flag=0;
			}
			else if( flag == 0 && delimiter(buff[i])==0)
				flag = 1;
		}
    }
    
    if(flag == 1)
    	tot_words++;
    
    printf("The file transfer is successful\n");
    printf("Size of the file = %d bytes, no. of words = %d\n",tot_bytes,tot_words);
    
    close(fd);
	close(sockfd); 
	return 0;
} 
