# nginx with letsencrypt

## Tools and stuff

I use the following setup on my Ubuntu server
- [nginx](http://nginx.org/) - Static websites and reverse proxy
- [letsencrypt](https://github.com/letsencrypt/letsencrypt) - Request SSL certificates
    - Requested with --webroot command to work alongside all running applications
- [cron](https://help.ubuntu.com/community/CronHowto) - Auto renew certificates every month or so

### Directoy setup

**letsencrypt executable**

I recommend that you link the `letsencrypt-auto` executable to `/bin/letsencrypt-auto` for easy access. Or add it to your `$PATH`.

**SSL certificate locations**

When requesting certificates with letsencrypt, they will reside under `/etc/letencrypt/live`, which is all fine, but it's a long route to write for each configuration. Therefore I have decided to symlink this direcrtory to `/opt/ssl`.

Run `$ ln -s /etc/letsencrypt/live/ /opt/ssl/` to set that up.

**ACME-challenge**

This is something letsencrypt does to verify your webserver, by putting a specific file under `http://<domain>/.well-known/acme-challence/some/path/to/file`.

These files must be reachable for each domain/subdomain, and therefore I thought it would be a great solution to collect all those in one single directory, called `/opt/ssl-challenge/` and point all nginx-configs to that specific location.

Run `$ mkdir /opt/ssl-challenge/` to fix that.

*Note:* This directory will be used in our `request_certs.sh` script.

### nginx config

Look inside `/nginx` to see examples of how to set up multiple domains/subdomains with a single certificate. Which also supports the acme-challenge.

**Note:** Since you might have several nignx config files, I refactored some of the logic to `snippets/` inside `nginx/` for easy reuse.

## Let's do this, ok?

First, you must have a list of domains that you want to support, where the first one will be used as a CN-name. It does not need to be a list of multiple domains, one is enough.
But, I would highly recommend that you put your TLD+1 domain first, and then all subdomains and probably other domains as well.

**Run the script**

Look inside `/request-certificate/`, modify the `example.com` to fit your needs, and run `$ ./request.sh example.com`

That should be it. Your webservie should reload automatically from the script. Visit your site and check that the exipration of your certificate has changed. You should also be able to verify that your subdomains are inside the certificate by exploring it on your browser.


**_IMPORTANT NOTE_**

If you are trying out this, be sure that you have the `--server <url>` option uncommented in `request.sh`.
This will prevent you from using up your rate limit on your try-and-fail approach.
However, the certificates you get from there will not be usable in production as the Certificate Authority is not recognized by any browser. They're called _happy hacker fake CA_, so, yeah. If you run the script and get a browser error stating the CA is invalid, and the name is _happy hacker fake CA_, you have done everything correct. _Probably_.

## Automatic renewal

So, you'd like to avoid updating the certificates automatically every 90 days or so? Me too.

For this example I'll assume you have `crontab` installed on your server.
If not, run `$ sudo apt-get install cron`

Run `$ crontab -e` to open crontab editor.
Add the line below to update the 1st of every month. Just to be safe.
```
0 0 1 * * bash /path/to/request.sh /path/to/example.com
```

Save and quit.

_Crontab may complain if you are missing an empty newline at the end of the crontab file._

Done.

Srsly.
