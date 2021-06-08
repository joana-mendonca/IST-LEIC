<html>
  <head>
    <meta charset="utf-8">
    <title>Locais Públicos</title>
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

    td:nth-of-type(5n+1) { width: 50px; }

    td:nth-of-type(5n+2) {
      width: 160px;
    }

    td:nth-of-type(5n+3) { width: 160px; }

    td:nth-of-type(5n+4) {
        width: calc(100% - 425px);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    td:nth-of-type(5n+5) { width: 80px;  text-align: center; }

    tbody tr:last-of-type td { width: 100%; }

    a.eliminar { text-decoration: none; cursor: pointer; }
    a.eliminar:hover { text-decoration: underline; }

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
      z-index: 2;
      font-size: 20px;
      position: absolute;
      width: 600px;
      height: 101px;
      border: 2px solid #888888;
      background-color: #c8c8c8;
      top: calc(50% - 50px);
      left: calc(50% - 300px);
    }

    #message {
      margin: 10px;
      width: calc(100% - 20px);
      text-align: center;
    }

    #buttons {
      display: flex;
      justify-content: center;
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

    input[type=submit] {
      margin: 0 10px;
      border-width: 0 1;
      border-color: transparent;
      cursor: pointer;
    }


    button#no { background-color: green }
    button#ye { background-color: red }

    #new_pdc {
      display: flex;
      height: 25px;
      background-color: transparent;
      margin: 0;
    }

    #new_pdc * {
      font-size: 16px;
      border: none;
      background-color: transparent;
      padding: 1px;
    }

    #new_pdc input[name=m_latitude] { width: 160px; margin-left: 46px; text-align: center; }
    #new_pdc input[name=m_longitude] { width: 160px; text-align: center; }
    #new_pdc input[name=m_nome] { flex-grow: 2; padding-left: 4px; margin-left: 2px; }
    #new_pdc input[type=submit] { width: 80px; margin: 0; }

    h1 {
      text-align: center;
      margin: 12px 0;
    }

    ::-webkit-scrollbar {
      width: 0px;
    }
  </style>
  <body>
    <h1>Locais Públicos</h1>
    <div id="confirm-delete" style="display: none;">
      <p id="message">De certeza que pretende <b>eliminar</b> o local <span></span>?</p>
      <div id="buttons">
        <form action="local_publico.php" method="post">
          <input type="hidden" name="m_latitude">
          <input type="hidden" name="m_longitude">
          <button type="button" id="no" onclick="document.getElementById('confirm-delete').style.display = 'none'">Cancelar</button>
          <button type="submit" id="ye">Sim</button>
        </form>
      </div>
    </div>
    <?php
      $m_latitude = $_REQUEST['m_latitude'];
      $m_longitude = $_REQUEST['m_longitude'];
      $m_nome = $_REQUEST['m_nome'];

      try {
        $host = "db.ist.utl.pt";
        $user ="ist426015";
        $password = "conacona";
        $dbname = $user;
        
        
        $db = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        if (isset($m_latitude) && isset($m_longitude) && !isset($m_nome)){
          $sql = "DELETE FROM local_publico WHERE latitude = " . $m_latitude . " AND longitude = '" . $m_longitude . "';";

          $result = $db->prepare($sql);
          $result->execute();
        }
        else if(isset($m_latitude) && isset($m_longitude) && isset($m_nome)){
          $sql = "INSERT INTO local_publico VALUES (" . $m_latitude . ", " . $m_longitude . ", '" . $m_nome . "');";

          $result = $db->prepare($sql);
          $result->execute();
        }
      
        $sql = "SELECT * FROM local_publico;";
        $result = $db->prepare($sql);
        $result->execute();

        echo("<table border=\"1\">\n");
        echo("<thead><tr>
          <td id=\"back\"><a href=\"index.html\">Back</a></td>
          <td>Latitude</td>
          <td>Longitude</td>
          <td>Nome</td>
          <td id=\"insert\"><a onclick=\"newAppear(event)\">Insert</a></td>
          </tr></thead>\n<tbody id='that_tbody'>");

        foreach($result as $row) {
          echo("<tr><td></td>");
          echo("<td class=\"ctr\">");
          echo($row['latitude']);
          echo("</td><td class=\"ctr\">");
          echo($row['longitude']);
          echo("</td><td>");
          echo($row['nome']);
          echo("</td><td>");
          echo("<a onclick=\"popUp(event)\" class=\"eliminar\">eliminar</a>");
          echo("</td></tr>\n");
        }
        echo("<tr style='display: none;'><td colspan='5'><form id='new_pdc' action='local_publico.php' method='post'>
          <input type='text' name='m_latitude' value='' style=''>
          <input type='text' name='m_longitude' value='' style=''>
          <input type='text' name='m_nome' value='' style=''>
          <input type='submit' value='Submeter'>
          </form></td></tr>");
        echo("</tbody>\n</table>\n");
      
        $db = null;
      }
      catch (PDOException $e) {
        echo("<p>ERROR: {$e->getMessage()}</p>");
      }
    ?>
    <script type="text/javascript">
      function popUp(evt) {
        cnfdel = document.getElementById("confirm-delete");
        tr = evt.srcElement.parentElement.parentElement;
        cnfdel.children[1].children[0].children[0].value = tr.children[1].innerHTML;
        cnfdel.children[1].children[0].children[1].value = tr.children[2].innerHTML;

        cnfdel.children[0].children[1].innerHTML = tr.children[3].innerHTML;
        cnfdel.style.display = 'block';
      }

      function newAppear(evt) {
        document.getElementById("new_pdc").parentElement.parentElement.style.display = 'flex';
        document.getElementById("that_tbody").scrollTo(0, document.body.scrollHeight);
        document.getElementById("new_pdc").children[0].focus();
      }
    </script>
  </body>
</html>