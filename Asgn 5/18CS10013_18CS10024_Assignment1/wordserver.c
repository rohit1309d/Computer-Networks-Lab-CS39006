#include <stdio.h> 
#include <stdlib.h> 
#include <unistd.h> 
#include <string.h> 
#include <sys/types.h> 
#include <sys/socket.h> 
#include <arpa/inet.h> 
#include <netinet/in.h> 

#define PORT 8080 
#define MAXLINE 1024 

int main() { 
    int sockfd; 
    char buffer[MAXLINE]; 
    struct sockaddr_in servaddr, cliaddr; 
    
    if ( (sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0 ) { 
        perror("socket creation failed"); 
        return 0;
    } 
    
    memset(&servaddr, 0, sizeof(servaddr)); 
    memset(&cliaddr, 0, sizeof(cliaddr)); 
    
    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr = INADDR_ANY; 
    servaddr.sin_port = htons(PORT); 
    
    
    if ( bind(sockfd, (const struct sockaddr *)&servaddr, sizeof(servaddr)) < 0 ) 
    { 
        perror("bind failed"); 
        return 0;
    } 

    printf("--------- Server running ----------\n");
    
    int len, n; 

    len = sizeof(cliaddr);

    char fname[MAXLINE];
    n = recvfrom(sockfd, (char *)fname, MAXLINE, MSG_WAITALL, ( struct sockaddr *) &cliaddr, &len); 
    fname[n] = '\0';

    FILE * fp;
    fp = fopen(fname, "r");

    if (fp == NULL)
    {
        char *error_msg = "FILE_NOT_FOUND";
        sendto(sockfd, (const char *)error_msg, strlen(error_msg), MSG_CONFIRM, (const struct sockaddr *) &cliaddr, len);
        return 0;
    }

    char msg[MAXLINE];

    fscanf(fp, "%s", msg);

    if (strcmp(msg, "HELLO") != 0)
    {
        char *error_msg = "WRONG_FILE_FORMAT";
        printf("Wrong file format\n");
        sendto(sockfd, (const char *)error_msg, strlen(error_msg), MSG_CONFIRM, (const struct sockaddr *) &cliaddr, len);
        return 0;
    }

    char* start = "FILE_FOUND";
    sendto(sockfd, (const char *)start, strlen(start), MSG_CONFIRM, (const struct sockaddr *) &cliaddr, len);

    while(fscanf(fp, "%s", msg) != EOF){
        n = recvfrom(sockfd, (char *)buffer, MAXLINE, MSG_WAITALL, ( struct sockaddr *) &cliaddr, &len); 
        buffer[n] = '\0'; 

        sendto(sockfd, (const char *)msg, strlen(msg), MSG_CONFIRM, (const struct sockaddr *) &cliaddr, len); 
    }

    fclose(fp);

    close(sockfd); 

    return 0; 
} 
