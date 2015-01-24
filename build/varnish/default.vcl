backend default {
    .host = "localhost";
    .port = "8080";
}

# Let all traffic through
sub vcl_recv {
    return(pass);
}