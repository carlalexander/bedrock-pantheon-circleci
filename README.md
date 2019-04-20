# Bedrock template project for Pantheon (CircleCI)

This is a project template for using [bedrock][1] with [Pantheon][2]. This 
project shows you how to use bedrock on Pantheon with [CircleCI][3] handling 
continuous deployment. 

## Creating a project

To create a new project, just use the following command:

```console
$ composer create-project carlalexander/bedrock-pantheon-circleci
```

You'll then need to update the environment variables in your project's `.env` 
file. You can read about all the Bedrock environment variables in the [Bedrock 
documentation][4].

## Configuration

By itself, the project template only has the code and configuration files 
required to work on the Pantheon and CircleCI platforms. Both platforms require
some additional configuration for the continuous deployment workflow to work.

### Configuring SSH

The first thing that you'll need to do is to grant CircleCI SSH access to your
account. To do that, you should create a special SSH key just for CircleCI. 
Start by running this command in your project directory:

```console
$ ssh-keygen -m pem -C "circleci"
```

This command will create two files, `id_rsa` and `id_rsa.pub`, in your project
directory. You'll use these two files to configure CircleCI and Pantheon.

**Important:** Do not commit the `id_rsa` and `id_rsa.pub` files into your 
project.

#### CircleCI

First, we're going to configure CircleCI. In the CircleCI application, go to 
your bedrock project’s settings by clicking the gear icon next to your project.

![Project settings][5]

There, you want to go to the **SSH Permissions** screen. You then want to click 
on the **Add SSH Key** button. This will open a modal window where you can enter
the SSH key that you want to add to your CircleCI project. The modal has two
fields: **Hostname** and **Private Key**.

![SSH key modal window][6]

For the **Hostname**, you want enter `drush.in`. This will limit the SSH key use
to only Pantheon servers. If you leave it empty, the SSH key will be used for
all SSH connections which we don't want.

The **Private Key** is the content of the `id_rsa` file that we created with the 
`ssh-keygen` command. The content of the `id_rsa` file will always start with:
`-----BEGIN RSA PRIVATE KEY-----`. Once you've filled the two form fields, you
want to click on **Add SSH Key** button to add the SSH key.

![SSH keys screen][7]

You should then see it appear in the list of SSH keys.

#### Pantheon

Next, you need to add the SSH key to your Pantheon account. From the dashboard, 
you want to go to the account page by clicking the **Account** tab.

![Account tab][8]

There you want to go to the **SSH Keys** section and fill the **Add an SSH Key**
form. For this form, you want to copy the public key instead of the private key.
You can find it in the `id_rsa.pub` file.

![Add an SSH key form][9]

The beginning of the file will always start with `ssh-rsa`. If you use the
`-C "circleci"` option with the `ssh-keygen` command, the file will end with
`circleci`. Once you've copied the content of the `id_rsa.pub` file, you want to
click on **Add Key**.

![SSH keys screen][10]

You should then see it appear in the list of SSH keys.

### Creating the initial .env file

Unlike a standard WordPress site, a Bedrock site uses environment variables to
manage sensitive credentials. These environment variables can come from 
different sources. The most important one being `.env` file which Bedrock uses 
instead of the standard WordPress `wp-config.php` file.

Pantheon won't create the initial `.env` file that your Bedrock site needs. 
You're going to have to create it yourself and upload it to the Pantheon server.
To easiest way to do that is by connecting to your Pantheon server using FTP and
creating the `.env` file.

![Connection Info][11]

To connect to your Pantheon site using FTP, go to your site admin panel in the
Pantheon dashboard. There, you'll see a **Connection Info** button to the right
as shown above. This will open a menu with all the credentials used to connect
to your Pantheon site.

![SFTP credentials][12]

You'll find the SFTP credentials at the bottom. Use these SFTP credentials to 
connect to your Pantheon site. Once connected, you want to go to the `files`
directory and create the `private` directory. You want to create your `.env` 
file in the `private` directory that you just created with the following:

```
WP_ENV=development
WP_SITEURL=${WP_HOME}/wp

# Generate your keys here: https://roots.io/salts.html
AUTH_KEY='generateme'
SECURE_AUTH_KEY='generateme'
LOGGED_IN_KEY='generateme'
NONCE_KEY='generateme'
AUTH_SALT='generateme'
SECURE_AUTH_SALT='generateme'
LOGGED_IN_SALT='generateme'
NONCE_SALT='generateme'
```

It's important that you replace all the keys with new ones that were generated 
[here][13]. You'll also notice that this is a more trimmed down `.env` file than 
what you're used to see with Bedrock. That's because Pantheon supplies a lot of 
the environment variables that we'd store in the `.env` file normally.

### CircleCI environment variables

For the CircleCI Pantheon deployment script to work, we need to configure some
project specific environment variables. To do that, you're going to have to go
back to your project's setting in CircleCI. You can access them by clicking on
the gear icon.

![Environment Variables screen][14]

There, you want to navigate to the **Environment Variables** screen. Next, 
you'll need to add specific environment variables. The following sections will
explain how to get the value for each environment variable.

#### TERMINUS_SITE

The `TERMINUS_SITE` environment variable is the name of the site that we're
deploying on the Pantheon platform. The easiest way to get that value is by 
going to your site on the Pantheon. In the admin panel, you want to click to 
visit the development version of the site.

![Development site button][15]

The URL for the development version of the site should look something like 
`http://dev-xxxxxxx.pantheonsite.io/`. The `xxxxxxx` is the name of site on the
Pantheon platform. You need to use that as the value of your `TERMINUS_SITE` 
environment variable.

![Adding TERMINUS_SITE][16]

#### TERMINUS_TOKEN

The `TERMINUS_TOKEN` environment variable is the token used by terminus to 
authenticate with the Pantheon platform. You create it by going to the **Machine
Tokens** section in the **Account** tab of the Pantheon dashboard. You then want
to click on **Create token** to create your machine token.

![Create new token page][17]

You'll need to give a name to identify your machine token. Once that's done, you
want to click on **Generate token**. This will generate the token and bring a
modal.

![Generate token modal][18]

Pantheon will only show you the machine token once. You can save it somewhere if
you need to. Otherwise, just head over to your project's settings in CircleCI 
and add the machine token as the value of your `TERMINUS_TOKEN` environment 
variable.

![Adding TERMINUS_TOKEN][19]

#### GITHUB_TOKEN (optional)

The deployment script will create [multidev][20]
environments whenever CircleCI is running for a pull request. These multidev
environments won't get cleaned up once the pull request gets merged. For that, 
you need to allow terminus to connect to your GitHub account.

To do that, you need to add the `GITHUB_TOKEN` environment variable. The value
of the `GITHUB_TOKEN` environment variable comes from creating a personal access 
token on GitHub. You can find a guide explaining how to create one [here][21].

![GitHub personal token][22]

Once created, GitHub will only show your personal token once. You can save it
somewhere if you want. Otherwise, just head over to your project's settings in 
CircleCI and add the machine token as the value of your `GITHUB_TOKEN` 
environment variable.

![Adding GITHUB_TOKEN][23]

## Acknowledgements

Thanks to the [Roots team][24] for creating and maintaining the Bedrock project. 
Also thanks to [Andrew Taylor][25] for his [repo][26] showing how to have 
advanced deployment workflow with WordPress and Pantheon.

[1]: https://roots.io/bedrock
[2]: https://pantheon.io
[3]: https://circleci.com
[4]: https://roots.io/bedrock/docs/installing-bedrock
[5]: https://d.pr/i/BzFFC6+
[6]: https://d.pr/i/ulneU6+
[7]: https://d.pr/i/mvzxau+
[8]: https://d.pr/i/ZqOSqh+
[9]: https://d.pr/i/U9WAYj+
[10]: https://d.pr/i/BTHff4+
[11]: https://d.pr/i/RnWLIb+
[12]: https://d.pr/i/1sbaUa+
[13]: https://roots.io/salts.html
[14]: https://d.pr/i/O9LCtn+
[15]: https://d.pr/i/rzNQNY+
[16]: https://d.pr/i/HFa5F8+
[17]: https://d.pr/i/nwaWux+
[18]: https://d.pr/i/VsbkpA+
[19]: https://d.pr/i/Mhq8b8+
[20]: https://pantheon.io/docs/multidev/
[21]: https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line
[22]: https://d.pr/i/rWkmLH+
[23]: https://d.pr/i/uf7WEg+
[24]: https://roots.io
[25]: http://www.ataylor.me/
[26]: https://github.com/ataylorme/Advanced-WordPress-on-Pantheon
