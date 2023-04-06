<!DOCTYPE html>
<html lang="en">

<head>
  <!--
##@Version           :  202303091846-git
# @@Author           :  Jason Hempstead
# @@Contact          :  git-admin@casjaysdev.com
# @@License          :  WTFPL
# @@ReadME           :  
# @@Copyright        :  Copyright: (c) 2023 Jason Hempstead, Casjays Developments
# @@Created          :  Thursday, Mar 09, 2023 18:46 EST
# @@File             :  index.php
# @@Description      :  php document
# @@Changelog        :  Updated header
# @@TODO             :  
# @@Other            :  
# @@Resource         :  
# @@Terminal App     :  no
# @@sudo/root        :  no
# @@Template         :  html
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-->

  <meta charset="utf-8" />
  <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0" />
  <meta name="robots" content="index, follow" />
  <meta name="generator" content="CasjaysDev" />

  <meta name="description" content="REPLACE_SERVER_SOFTWARE container" />
  <meta property="og:title" content="REPLACE_SERVER_SOFTWARE container" />
  <meta property="og:locale" content="en_US" />
  <meta property="og:type" content="website" />
  <meta property="og:image" content="./images/favicon.ico" />
  <meta property="og:url" content="" />

  <meta name="theme-color" content="#000000" />
  <link rel="manifest" href="./site.webmanifest" />

  <link rel="icon" type="image/icon png" href="./images/icon.png" />
  <link rel="apple-touch-icon" href="./images/icon.png" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.css" />
  <link rel="stylesheet" type="text/css" href="./css/cookieconsent.css" />
  <link rel="stylesheet" href="./css/bootstrap.css" />
  <link rel="stylesheet" href="./css/index.css" />
  <script src="./js/errorpages/isup.js"></script>
  <script src="./js/errorpages/homepage.js"></script>
  <script src="./js/errorpages/loaddomain.js"></script>
  <script src="./js/jquery/default.js"></script>
  <script src="./js/passprotect.min.js" defer></script>
  <script src="./js/bootstrap.min.js" defer></script>
  <script src="./js/app.js" defer></script>
</head>

<body class="container text-center" style="align-items: center; justify-content: center">
  <h1 class="m-5">Congratulations</h1>
  <h2>
    Your REPLACE_SERVER_SOFTWARE container has been setup.<br />
    This file is located in:
    <?php echo $_SERVER['DOCUMENT_ROOT']; ?>
    <br /><br />

    SERVER:
    <?php echo $_SERVER['SERVER_SOFTWARE']; ?> <br />
    SERVER Address:
    <?php echo $_SERVER['SERVER_ADDR']; ?> <br />

  </h2>
  <br /><br />
  <br /><br />

  <br /><br />
  <!-- Begin EU compliant -->
  <div class="text-center align-items-center fs-3">
    <script src="https://cdn.jsdelivr.net/npm/cookieconsent@3/build/cookieconsent.min.js" data-cfasync="false"></script>
    <script>
      window.cookieconsent.initialise({
        palette: {
          popup: {
            background: '#64386b',
            text: '#ffcdfd',
          },
          button: {
            background: '#f8a8ff',
            text: '#3f0045',
          },
        },
        theme: 'edgeless',
        content: {
          message:
            'This site uses cookie and in accordance with the EU GDPR<br />law this message is being displayed.<br />',
          dismiss: 'Dismiss',
          link: 'CasjaysDev Privacy Policy',
          href: 'https://casjaysdev.com/policy',
        },
      });
    </script>
  </div>
  <!-- End EU compliant -->
</body>

</html>
