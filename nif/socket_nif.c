#include "erl_nif.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <stdio.h>

static ERL_NIF_TERM sock_socket_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    int sock;
    sock = socket(AF_INET,SOCK_DGRAM,IPPROTO_UDP);
    if (sock < 0) {
	return enif_make_badarg(env);
    }
    return enif_make_int(env, sock);
}


static ERL_NIF_TERM sock_bind_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    int port, sock;
    struct sockaddr_in sock_addr;

    if (!enif_get_int(env, argv[0], &sock)) {
        return enif_make_badarg(env);
    }
    if (!enif_get_int(env, argv[1], &port)) {
        return enif_make_badarg(env);
    }

    sock_addr.sin_family = AF_INET;
    sock_addr.sin_port = htons(port);
    sock_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    if (bind(sock,(struct sockaddr*)&sock_addr,sizeof(sock_addr)) != 0) {
        return enif_make_badarg(env);
    }
    return enif_make_int(env, sock);

}

static ERL_NIF_TERM sock_send_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    int sock,dest_port,ret;
    struct sockaddr_in sock_addr;
    char *data = "TEST\n";
    struct sockaddr_in destination;

    if (!enif_get_int(env, argv[0], &sock)) {
        return enif_make_badarg(env);
    }
    if (!enif_get_int(env, argv[1], &dest_port)) {
        return enif_make_badarg(env);
    }

    destination.sin_family = AF_INET;
    destination.sin_port = htons(dest_port);
    inet_pton(AF_INET,"127.0.0.1",&destination.sin_addr.s_addr);
    ret = sendto(sock,data,5,0,(struct sockaddr*)&destination,sizeof(destination));
    if (ret <= 0) {
        return enif_make_badarg(env);
    }
    return enif_make_int(env, ret);
}

static ERL_NIF_TERM sock_loopback_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    int ret,sock;
    socklen_t addr_len;
    char data[2000];
    struct sockaddr_in source;
    
    if (!enif_get_int(env, argv[0], &sock)) {
        return enif_make_badarg(env);
    }
    
    ret = recvfrom(sock,data,sizeof(data),0,(struct sockaddr*)&source,&addr_len);
//    printf("Data received %d\n",ret);
    ret = sendto(sock,data,ret,0,(struct sockaddr*)&source,addr_len);

    return enif_make_int(env, ret);
}


static ERL_NIF_TERM sock_close_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    int sock, ret;
    if (!enif_get_int(env, argv[0], &sock)) {
	return enif_make_badarg(env);
    }
    ret = close(sock);
    return enif_make_int(env, ret);
}

static ErlNifFunc nif_funcs[] = {
    {"socket", 0, sock_socket_nif},
    {"bind", 2, sock_bind_nif},
    {"send", 2, sock_send_nif},
    {"loopback", 1, sock_loopback_nif},
    {"close", 1, sock_close_nif}
};

ERL_NIF_INIT(socket_nif, nif_funcs, NULL, NULL, NULL, NULL);

