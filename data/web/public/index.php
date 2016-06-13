<?php
$host_name = gethostname();
$host_name_parts = explode("-", $host_name);
$ready_name = count($host_name_parts) == 4 ? $host_name_parts[1] : $host_name;

$mysqlConfig = parse_ini_file('/data/web/.my.cnf', true);
$redisConfig = parseRedisConf('/etc/redis/redis.conf');
$varnishSecret = file_get_contents('/etc/varnish/secret');

/**
 * Parses the Redis config file for parameters.
 * @param $file
 * @return array
 */
function parseRedisConf($file){
    $config = array();
    if(is_file($file)){
        $file = file_get_contents($file);
    }
    foreach(preg_split("/((\r?\n)|(\r\n?))/", $file) as $line){
        if(substr($line, 0, 4) == "port" || substr($line, 0, 4) == "bind"){
            $exline = explode(" ", $line);
            $config[$exline[0]] = $exline[1];
        }

    }
    return $config;
}

/**
 * Formats an URL which redirects to the PHP info page.
 * @return string
 */
function getPHPInfoPage(){
    $phpInfoPage = "https://";
    if(!$_SERVER['HTTPS']){
        $phpInfoPage = "http://";
    }
    $phpInfoPage .= $_SERVER['HTTP_HOST'].$_SERVER['PHP_SELF']."?info=true";
    return $phpInfoPage;
}

if($_GET['info']):
    phpinfo();
Else:
    ?>
    <!DOCTYPE html>
    <html>
    <head lang="en">
        <meta charset="UTF-8">
        <title>Your Hypernode test environment is ready for use</title>
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <base href="http://hypernode.com" target="_blank">
        <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Open+Sans:400,300,700"/>
        <link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css">
        <style>
            body {
                background-color: #004067;
                color: rgb(220, 242, 250);
                font-family: 'Open Sans', sans-serif;
                font-weight: 300;
            }

            header {
                background-color: #00374c;
                border-bottom: 1px solid #dcf2fa;
            }

            header a {
                color: #9dd875;
                text-decoration: none;
            }

            header a:hover {
                color: #9dd875;
                text-decoration: underline;
            }

            .nav {
                margin-top: 50px;
            }

            nav li:hover {
                background-color: #00374c;
            }

            nav #vagrant {
                background-color: #9dd875;
                color: #004067;
                padding: 20px;
            }

            nav h3 {
                margin: 0;
            }

            .navbar {
                border: 0;
            }

            .navbar-brand {
                padding: 40px 15px;
                height: 100px;
                max-width: 250px;
            }

            .navbar-toggle {
                margin-top: 50px;
            }

            .navbar-toggle:hover, .navbar-toggle:focus {
                background-color: #429627;
            }

            .navbar-toggle .icon-bar {
                background-color: #9dd875;
            }

            header .jumbotron {
                background-color: #00374c;
                color: inherit;
                padding-bottom: 0px;
                margin-bottom: 0px;
            }

            .jumbotron .container {
                max-width: 100%;
                background-image: url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAA8oAAAHCCAMAAAAAfcBCAAAC5VBMVEUAAAALQWYLQWYLQWYLQWYLQWYLQWYLQWYLQWYLQWYLQWYLQWYLQWYLQWYLQWYLQWYLQWYLQWYhVXc3aYlCc5FNfZq64fG64fGhyt14pb2Ouc664fG64fG64fG64fG64fGZwdKOt8i64fG64fG64fGv1ueCrL5WgpU1YnYTQ1cIOE1Ld4t3orSkzN0pWGxhjZ+64fG64fG64fFAbYC64fEeTWK64fGkzeBjkaxsl6ljkawWS2+v1+htm7Sdxtqq0uRolrBjkay64fGZw9csX4AaTnIaTnJYh6OKtcu64fFVgpSLtsd1obI0YnY/bYCs1uW34O+ArLxKd4qt2+1zv+FMrNl9xOOhy9uWwdGQzedgtd1Dp9dqut+k1+spWGua0ukmmdEclM9Wsds5otVgjJ4eTWEvntOHyOWDr8ZsnLB5sstql6ihyt2jzN6jzN644O9ru+B1v+KTzulbmbU6eZdmpMB5rcSCrL254fB+xOSb0uqYwdIhVXcdUXRjnbZmqcdWh5xambRbnr14rcMmWntjkayArMOZwtQ3aIc2Z4NMfJefx9iTvdKr0+Os1OSiytuArMMXTG+ZwtWkzN6OuM2OuMuNvM+Px9+XxtmZzOGOwtet1eZuqMFHlblCfpiOt8iOt8plo798vtuCscWUvc6Wv9CWv9CLtsqXwNSDrcGDrsKDrb9tmrN4o7c2Z4RMe5U2aIZBcY13orV4pLqDrsRsmKttmrF4o7htma5ij6VAcoiFw90JPlV6uNMfU2l3p7oqXXRLfZKPwtePwthikKo+kLd3orOSzug5eZZtmbCNt8hijqSZx9phjaGazOJXjaRsnLErY3xxs9Ftorg1aH5hkqZikKhtmKxMfJlMepE1ZXxXhqFXhJtAb4cLQGSRust4pLuiy90IOE0qWnIJOlJvnLWXwdVzn7MfTmWXwdVhjqJCcpAWSmxLeY9WhJksXn9XhZ0IOU9ij6cfUWtBco4JOlNLeY71pEvDAAAA6nRSTlMAEABAYIBwv6+f7/8wz98gUI//////IABw////z59gEP//cIDv//////////////9AvzD/UP/f/7///////7+v70CP//+/AP+vr//////////////////////////////////////////////f7wD/////////////////gJ/////////PIDD/////z4+/z++/7////////////8////8A/////9/vAO/v////////////////////////////////////////////////////////////////////////z//vv//v31Dv/5/hOFJxAABAPklEQVR4AezTQW5CMQBDQXCa8CGU+x+3d7CUBerM3vLq3f4tAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAuKcyyt0934Nbvgc/qYzR3p2AlJmprNHenYCUeaQyR3t3AlLmGmnMmca4cgJSZq40njONNXMCUmZeaTxmGtfMCUiZ9epSfqTxWjkBKTP2O4XfKuX3HjkDKUt5pbCrlNexlJGylJ8p7FcKz1MpI2X2J4W9U/jsnIGU2X/s292OnToWRWF5GfPjATa8/8ueixN1LtNzqUuhxfyuC+1Q0shmUjIzZBVCNyHsZzhlgyWV8gzZAvEzzCnbxZFKuYbs4ApzyvYzNkbI1lTKgy3MKdvP2KCEqsEdqsIfUzanbGfkPJkqG7RQ3fBESjnDnPJXnHektExgRyblB1qkrCXMKX/Gnk75CtWWqfJKp7yHOeXv2GdkLEBJpLwlpjJLZNQnzCl/R3tynQA1RBds2Q/S7XeYU/6O2tMptxCRSLllU57MMKf8ISy5UBJZAoRog1yTbYQ55S/ZrtClsiwAyc/RjSPMKX9J48ymXPWHciJ1jW5hCXPKPnr8Rx1oiSxPfSr3SNiYYU75U6CkUoEtkXLNfIxuMsKc8rdsrMmUe0haIuWeTPlhD3PK3/Iwkilz6ikvoTjJpVw6a3yLU7YbasgawKpf0kKxArSQLXDGtzhlK7CnUlav2wFa5hLZRY+vccp2wcyl3PVn8icUPZdyhT2+xinbk6wFOOWUN3kqU0N1wBpf45TthpFMeQnBkFNecikXPJX/r1O2Oz2WWXIpHyFATvnIpbwC6V/h3+eUrZVIGclzxDDklJG/xynZ+9GVJ/4+p2z1iZQDmCECtMuKnPIEgMRgoEXKU+MFnLJdZ2QswBEi1LFc5TCXXMo7kEvyvOINnLItW2RMoJfQXAA8WspaZA8A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);
                background-position: bottom;
                background-repeat: no-repeat;
                min-height: 600px;
                text-align: center;
            }

            @media (max-width: 992px){
                .jumbotron .container{
                    background-image:none;
                }
            }

            .jumbotron h1 {
                font-size: 36px;
                font-family: inherit;
                font-weight: inherit;
                text-align: inherit;
            }

            .navbar-brand img {
                width: 70%;
            }
        </style>
    </head>
    <body>
    <header>
        <nav class="navbar" role="navigation">
            <div id="vagrant">
                <div class="text-center"><h3>test environment for <?php echo $ready_name; ?></h3></div>
            </div>
            <div class="container">
                <div class="navbar-header">
                    <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
                        <span class="sr-only">Toggle navigation</span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                    </button>
                    <a class="navbar-brand" href=""><img alt="Hypernode"
                                                         src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAARoAAABgCAMAAAD1o02bAAAAM1BMVEUAAAAngr0ngr0ngr0ngr0ngr0ngr0ngr0ngr0ngr0ngr0ngr0ngr0ngr0ngr0ngr0ngr1G2G0/AAAAEHRSTlMAv0CA7xAgn2DfzzCPcFCvNjJDRwAABLtJREFUeF7tm2mTsyoQRpt1UdT+/7/2TsjyBMGKiXMnbwnnw5QFTEdPIc2S0EvkpJQfaUXHOs2JoAyBjnUMdF1OFwM5HblwiY62ixG8gbNdTEmX4wW/wI1tigm8AyG7mESXYzbEdDlK85uEmVrADPwBrmUz3c3CHzLRyfH8KdrSuQlcp79Skj9H06lRXGHQvCIEriDpzAgu8UXWckSuuYFYc8FSvGfaEJlqyxMzckma6IZivI1coFtL3bZ40RT9MFWbnhfHJVSokVu5zNN5CcfURDotho+pGei0zAfVsKGzEvnYMMyyoQnfdvJ2XEHRWeEa4uWUD4jG1paebOAMZ4xra4U5cZ1QKtBcZ2xtg69v9Wmu07ezLB8n9G3hTexZJ3zHmemMDPwLRNpkFD+M6TIKIa4tL2ULJebLdVIrlUg3o8WEXhjFHcQZHw0VGqaYKl35yyUq/KWxdmg6O6GZOVw+B4hnItaWBxG0icRSQjxaOqT8dN9mvUPtTHWqLmndMJps5mof9cXho/ZUxlwgpz7jPc6basZHXrPodIoBD2afGhaZGgc1MHPHV3TrcVON4l9BvqcmXeqHD1uqYbFPDR6YE3alJjLQthJT239Mjb8P3gEb7xc1g5TSC851DvKOgRoiM6eGQ6bGoR5TEzdP+laJmHMMNwtQM8kbI5YJRxnfVJOUuNubJaFGQJxb6QR49AUSiK9Y1N8fT9FtYawpjzk933vR+Y3+82EYj2fIXSeMUIO0KXaomZOMTI271SNQgO4ZMWEu5mrAKPgwzrytxlyHCZ3+FmrcO2pMpobttR6FER+o1jEDLqHmD4Aapy7c7wNPP6fM/arXBHXF73mh2F3rkQlnxFzWamJu0akr9u/UAJGdCw7oz8VYE4tsIlZq7PJ8evrYSLFQgy4LIZmarIMB+U01eGi7VmMUFh/baoQI9wwANaljujfUzP+kGo8jc6jRQgxouK0GeHpWk4K6/Wqmr6sZxAUNNdiUl5ma6vRMY2FTNIyUqbkG/fiFGrBWqyDVa6biX9/MUFARqKpmSJ+wmaFAWKnxUIPChMb4hZgDQsDisW+CusNqkE5LNYMneqVGSimw+QoLIVMT8mXbhJi4uWWfGsc78cfVUKkm5WlpiV6ruYfWJo/mMzUuWXzkeYuY6Ah+nxrey/I/qEH1PjW0IAKiDVBztyfJxNQbs5jWa7j9RTXiD9UAkauxGLARTXICasFcizlVH11+vucXv60G74tbRRPPakYGSy2mo7qaA2PN19VgcWwRDTOp8lhgMJWYkfaq8bwT+3U1uFwQDTrX62etypjaWdqtZvz1kyeDLagx7RGBSw0Uk0U1GOUz46OhJESXiIZ6AtYrJVf3pNS0+jCZYahAH0xQ/ScuE7WHOrjh2X/JQS3yOxO+dg96FbVI5B3M1CL2yKymp29PbWJ0H4S3GF+4GQx1N91MgXG8hVbUODZwFWWoeQRXkdQRxS+9Q3io6WqUUYFvCE8CaroaIpqj+EGNRJmargZ0NV1NV9PVdDVdTVfT1XQ1XU0L4Dt9riyaqHWU5gthrhU1jSvPDkRW1CyqPIyLxXZWP6QLZdFAzTKVXxdRZVE/vuQJI00fbaJ4xteKmqbzH5wjP7BojybsAAAAAElFTkSuQmCC"/></a>
                </div>
                <div class="collapse navbar-collapse">
                    <ul class="nav navbar-nav navbar-right">
                        <li><a href="<?=  getPHPInfoPage() ?>">PHP Info</a></li>
                        <li><a href="http://support.hypernode.com/" target="_blank">support</a></li>
                    </ul>
                </div>
            </div>
        </nav>

        <div class="jumbotron">
            <div class="container">
                <div class="row">
                    <div class="center-block">
                        <h1>Your Hypernode test environment is ready for use</h1>
                        <p>Please follow our Getting Started guide at <a
                                href="http://support.hypernode.com/getting-started.html">support.hypernode.com</a>.</p>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-4">
                        <table class="table">
                            <thead>
                            <tr>
                                <th colspan="2">MySQL</th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr>
                                <td>Host</td>
                                <td>mysqlmaster</td>
                            </tr>
                            <tr>
                                <td>User</td>
                                <td><?= $mysqlConfig['client']['user'] ?></td>
                            </tr>
                            <tr>
                                <td>Pass</td>
                                <td><?= $mysqlConfig['client']['password'] ?></td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="col-md-4">
                        <table class="table">
                            <thead>
                            <tr>
                                <th colspan="2">
                                    Redis
                                </th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr>
                                <td>Server</td>
                                <td>redismaster</td>
                            </tr>
                            <tr>
                                <td>Port</td>
                                <td><?= $redisConfig['port'] ?></td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="col-md-4">
                        <table class="table">
                            <thead>
                            <tr>
                                <th colspan="2">
                                    Varnish
                                </th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr>
                                <td>Server list</td>
                                <td>varnish:6082 </td>
                            </tr>
                            <tr>
                                <td>Secret</td>
                                <td><?= $varnishSecret ?></td>
                            </tr>
                            <tr>
                                <td>Backend Host</td>
                                <td>varnish</td>
                            </tr>
                            <tr>
                                <td>Backend Port</td>
                                <td>8080</td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </header>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
    <script src="https://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>
    </body>
    </html>
    <?php
endif;
?>