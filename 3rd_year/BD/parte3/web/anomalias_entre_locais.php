<html>
  <head>
    <meta charset="utf-8">
    <title>Anomalias entre dois locais públicos</title>
  </head>
  <style type="text/css">
    body {
      margin: 0;
      font-family: sans-serif;
      overflow: hidden;
    }

    table {
      width: 100%;
      display: block;
      border-collapse: collapse;
      border: 0;
    }

    thead, tbody { display: block; width: 100%; }

    tbody {
      width: 100%;
      height: calc(100% - 26px - 61px);
      overflow-y: scroll;
    }

    tr {
      height: 25px;
      width: 100%;
      display: flex;
      align-items: center;
    }
    thead tr { border-bottom: 1px solid black; text-align: center; font-weight: bold; }
    tbody tr { border-bottom: 1px solid #888888; }
    tbody tr:nth-of-type(even) { background-color: #e8e8e8; }

    td { border: 0; height: 25px; line-height: 25px; }

    td:nth-of-type(6n+1) { width: 50px; }

    td:nth-of-type(6n+2) { width: 200px; }
    td:nth-of-type(6n+3) { width: 135px; }
    td:nth-of-type(6n+4) { width: 135px; }
    td:nth-of-type(6n+5) { width: 135px; }

    td:nth-of-type(6n+6) {
      flex-grow: 2;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    tbody tr:last-of-type td { width: 100%; }

    a.editar, a.eliminar { text-decoration: none; cursor: pointer; }
    a.editar:hover, a.eliminar:hover { text-decoration: underline; }

    a.editar { color: blue; }
    a.eliminar { color: red; }

    td.ctr {
      text-align: center;
    }

    #back {
      border-right: 1px solid black;
    }

    #insert a {
      font-size: 20px;
      text-decoration: none;
      color: blue;
      cursor: pointer;
    }

    #back a {
      text-decoration: none;
      color: blue;
      width: 50px;
      height: 100%;
    }

    #confirm-delete {
      z-index: 5;
      font-size: 20px;
      position: absolute;
      width: 330px;
      height: 101px;
      border: 2px solid #888888;
      background-color: #c8c8c8;
      top: calc(50% - 50px);
      left: calc(50% - 165px);
    }

    #message {
      margin: 10px;
      width: calc(100% - 20px);
      text-align: center;
    }

    #buttons button {
      font-size: 18px;
      margin: 0 5px 10px 5px;
      padding: 0;
      width: 100px;
      line-height: 25px;
      border: none;
      color: white;
      cursor: pointer;
    }

    span.thisspan {
      position: relative;
      z-index: 2;
      padding-left: 4px;
    }

    #main_form { height: 25px; padding: 0 15px; display: flex; margin: 0; }

    #main_form * { font-size: 16px; margin: 0 15px; flex-grow: 2; text-align: center; }
    #main_form input[type=submit] { width: 105px; margin: 0; flex-grow: 0; }

    h1 {
      text-align: center;
      margin: 12px 0;
    }

    ::-webkit-scrollbar {
      width: 0px;
    }
  </style>
  <body>
    <h1>Anomalias numa área em volta de um local nos últimos três meses</h1>
    <?php
      $parsed1; $parsed2;
      try {
        $last_id = 0;
        $host = "db.ist.utl.pt";
        $user ="ist426015";
        $password = "conacona";
        $dbname = $user;

        $db = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        if ((isset($_REQUEST['local1']) && isset($_REQUEST['local2'])) && (!empty($_REQUEST['local1']) && !empty($_REQUEST['local2']))) {
          $search = array("array", "(", ")", "'");
          $parsed1 = explode(',', str_replace($search, '', $_REQUEST['local1']));
          $parsed2 = explode(',', str_replace($search, '', $_REQUEST['local2']));

          $sql = "
            SELECT anomalia_id, ts, latitude, longitude, lingua, anomalia_descricao
            FROM anomalia NATURAL JOIN incidencia NATURAL JOIN item
            WHERE ((latitude BETWEEN " . $parsed1[0] . " AND " . $parsed2[0] . ") AND
                  (longitude BETWEEN " . $parsed1[1] . " AND " . $parsed2[1] . ")) OR
                  ((latitude BETWEEN " . $parsed2[0] . " AND " . $parsed1[0] . ") AND
                  (longitude BETWEEN " . $parsed2[1] . " AND " . $parsed1[1] . "))
            ORDER BY anomalia_id;";
          $result = $db->prepare($sql);
          $result->execute();
        }

        $sql2 = "SELECT * FROM local_publico ORDER BY nome;";
        $result2 = $db->prepare($sql2);
        $result2->execute();

        echo("<table border=\"1\">\n");
        echo("<thead><tr>
          <td id=\"back\"><a href=\"index.html\">Back</a></td>
          <td>Data/Hora</td>
          <td>Latitude</td>
          <td>Longitude</td>
          <td>Língua</td>
          <td>Descrição</td>
          </tr></thead>\n<tbody id='that_tbody'>");

        foreach($result as $row) {
          echo("<tr><td class=\"ctr\">");
          echo($row['anomalia_id']);
          echo("</td><td class=\"ctr\">");
          echo($row['ts']);
          echo("</td><td class=\"ctr\">");
          echo($row['latitude']);
          echo("</td><td class=\"ctr\">");
          echo($row['longitude']);
          echo("</td><td class=\"ctr\">");
          echo($row['lingua']);
          echo("</td><td>");
          echo($row['anomalia_descricao']);
          echo("</td></tr>\n");
        }

        echo("<tr><td colspan='5'><form id='main_form' action='anomalias_entre_locais.php' mathod='post'>");

        ob_start();
        foreach($result2 as $row) {
          echo("<option value='array(" . $row['latitude'] . ", " . $row['longitude'] . ", " . $row['nome'] . ")'>" . $row['nome'] . "</option>");
        }
        $output = ob_get_clean();

        echo("<select name='local1'><option value=''>-- Seleccione o local 1... --</option>" . $output . "</select>");
        echo("<input type='submit' value='Submeter'>");
        echo("<select name='local2'><option value=''>-- Seleccione o local 2... --</option>" . $output . "</select>");

        echo("</form>");
        echo("</tbody>\n</table>\n");
      
        $db = null;
      }
      catch (PDOException $e) {
        echo("<p>ERROR: {$e->getMessage()}</p>");
      }
    ?>
    <script type="text/javascript">
      var s1 = document.getElementById("main_form").children[0];
      var s2 = document.getElementById("main_form").children[2];

      for (var i = 0; i < s1.children.length; i++) {
        if (s1.children[i].value === "array(<?php echo $parsed1[0]; ?>,<?php echo $parsed1[1]; ?>,<?php echo $parsed1[2]; ?>)") break;
      }
      if (i == s1.children.length)s1.children[0].selected = true;
      s1.children[i].selected = true;

      for (var i = 0; i < s2.children.length; i++) {
        if (s2.children[i].value === "array(<?php echo $parsed2[0]; ?>,<?php echo $parsed2[1]; ?>,<?php echo $parsed2[2]; ?>)") break;
      }
      if (i == s2.children.length)s2.children[0].selected = true;
      s2.children[i].selected = true;
    </script>
  </body>
</html>