<html>
  <head>
    <meta charset="utf-8">
    <title>Utilizadores</title>
  </head>
  <style type="text/css">
    body {
      margin: 0;
      font-family: sans-serif;
      overflow: hidden;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      border: 0;
    }

    table th {
      border: none;
      padding: 0;
    }

    table tr {
      height: 25px;
    }

    table td, table th { border-right: 0; border-left: 0; }

    table tbody tr {
      border-bottom: 1px solid #888888;
    }

    table thead tr {
      border-bottom: 1px solid black;
    }

    tbody {
      width: 100%;
      height: calc(100% - 26px - 61px);
      overflow-y: scroll;
    }

    table th:nth-of-type(1) { width: 50px; }

    table a.editar, table a.eliminar { text-decoration: none; }
    table a.editar:hover, table a.eliminar:hover { text-decoration: underline; }

    table a.editar { color: blue; }
    table a.eliminar { color: red; }

    td.ctr {
      text-align: center;
    }

    th#back {
      border-right: 1px solid #888888;
    }

    #back a {
      text-decoration: none;
      color: blue;
      width: 50px;
      height: 100%;
    }

    h1 {
      text-align: center;
      margin: 12px 0;
    }
  </style>
  <body>
    <h1>Utilizadores</h1>
    <?php
      try {
        $host = "db.ist.utl.pt";
        $user ="ist426015";
        $password = "conacona";
        $dbname = $user;
        
        $db = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
      
        $sql = "SELECT email FROM utilizador ORDER BY email;";
        $result = $db->prepare($sql);
        $result->execute();
           
        echo("<table border=\"1\">\n");
        echo("<thead><tr><th id=\"back\"><a href=\"index.html\">Back</a></th><th>E-mail</th></tr></thead>\n<tbody>");

        foreach($result as $row) {
          echo("<tr><td></td><td>");
          echo($row['email']);
          echo("</td></tr>\n");
        }
        echo("</tbody></table>\n");
      
        $db = null;
      }
      catch (PDOException $e) {
        echo("<p>ERROR: {$e->getMessage()}</p>");
      }
    ?>
  </body>
</html>