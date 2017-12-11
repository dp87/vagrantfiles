# Monica - Personal Relationship Manager

GitHub project: https://github.com/monicahq/monica

### Instructions

1. Create a folder named `Monica`
2. Put the `Vagrantfile` and `provision.sh` script in the `Monica` folder
3. `cd Monica`
4. `vagrant init ubuntu/xenial64`
5. `vagrant up`

Because of all the steps involved in getting Monica up and running, I have decided not to silence command output so you can see everything that is happening in the terminal, and more easily spot errors during the installation process (if any).

### Database users

* Root database user
* * Username: `root`
* * Password: `changeme`
* Monica database user
* * Username: `monica`
* * Password: `changeme`

### Apache configuration

* The project is installed in `/var/www/html/monica`
* The root folder for the web server is `/var/www/html/monica/public`

You still have to configure your own SMTP server details in the `.env` configuration file inside `/var/www/html/monica/`.
