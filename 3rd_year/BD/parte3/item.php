<html>
  <head>
    <meta charset="utf-8">
    <title>Items</title>
  </head>
  <style type="text/css">
    body {
      margin: 0;
      font-family: sans-serif;
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

    td:nth-of-type(6n+2) {
      width: 450px;
    }

    td:nth-of-type(6n+3) { 
      width: 1000px; 
      text-align: center;
    }

    td:nth-of-type(6n+4) {
        width: 160px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        text-align: center;
    }

    td:nth-of-type(6n+5) { width: 160px;  text-align: center; }

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
      width: 300px;
      height: 101px;
      border: 2px solid #888888;
      background-color: #c8c8c8;
      top: calc(50% - 50px);
      left: calc(50% - 150px);
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
      border: 0;
      margin: 0;
    }

    #new_pdc * {
      font-size: 16px;
      border: none;
      background-color: transparent;
      text-align: center;
    }

    #new_pdc input[name=m_item_id] { width: 52px; }
    #new_pdc input[name=m_item_descricao] { width: 452px;}
    #new_pdc input[name=m_localizacao] { flex-grow: 2; }
    #new_pdc select[name=m_coordenadas] { width: 324px; }
    #new_pdc input[type=submit] { width: 105px; margin: 0; }

    h1 {
      text-align: center;
      margin: 12px 0;
    }

    ::-webkit-scrollbar {
      width: 0px;
    }
  </style>
  <body>
    <h1>Itens</h1>
    <div id="confirm-delete" style="display: none;">
      <p id="message">De certeza que pretende <b>eliminar</b> o item <span></span>?</p>
      <div id="buttons">
        <form action="item.php" method="post">
          <input type="hidden" name="m_item_id">
          <button type="button" id="no" onclick="document.getElementById('confirm-delete').style.display = 'none'">Cancelar</button>
          <button type="submit" id="ye">Sim</button>
        </form>
      </div>
    </div>
    <?php
      $m_item_id = $_REQUEST['m_item_id'];
      $m_item_descricao = $_REQUEST['m_item_descricao'];
      $m_localizacao = $_REQUEST['m_localizacao'];
      $m_latitude = $_REQUEST['m_latitude'];
      $m_longitude = $_REQUEST['m_longitude'];
      $m_coordenadas = $_REQUEST['m_coordenadas'];

      try {
        $last_id = 0;
        $host = "db.ist.utl.pt";
        $user ="ist426015";
        $password = "conacona";
        $dbname = $user;
        
        
        $db = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        if ((isset($m_item_id) && !empty($m_item_id)) & !(isset($m_item_descricao) && !empty($m_item_descricao))){
          $sql = "DELETE FROM item WHERE item_id = '" . $m_item_id . "';";

          $result = $db->prepare($sql);
          $result->execute();
        }
        else if((isset($m_item_id) && !empty($m_item_id)) &&
                (isset($m_item_descricao) && !empty($m_item_descricao)) &&
                (isset($m_localizacao) && !empty($m_localizacao)) &&
                (isset($m_coordenadas) && !empty($m_coordenadas))) {
          $search = array("array", "(", ")", "'");
          $parsed1 = explode(',', str_replace($search, '', $m_coordenadas));

          $sql = "INSERT INTO item VALUES ('" . $m_item_id . "', '" . $m_item_descricao . "', '" . $m_localizacao . "' , " . $parsed1[0] . " , " . $parsed1[1] . ");";

          $result = $db->prepare($sql);
          $result->execute();
        }
      
        $sql = "SELECT * FROM item;";
        $result = $db->prepare($sql);
        $result->execute();

        $sql2 = "SELECT * FROM local_publico;";
        $result2 = $db->prepare($sql2);
        $result2->execute();

        echo("<table border=\"1\">\n");
        echo("<thead><tr>
          <td id=\"back\"><a href=\"index.html\">Back</a></td>
          <td>Descricao</td>
          <td>Localizacao</td>
          <td>Latitude</td>
          <td>Longitude</td>
          <td id=\"insert\"><a onclick=\"newAppear(event)\" class=\"add\">Inserir</a></td>
          </tr></thead>\n<tbody id=\"that_tbody\">");

        foreach($result as $row) {
          echo("<td class=\"ctr\">");
          echo($row['item_id']);
          echo("</td><td class=\"ctr\">");
          echo($row['item_descricao']);
          echo("</td><td>");
          echo($row['localizacao']);
          echo("</td><td>");
          echo($row['latitude']);
          echo("</td><td>");
          echo($row['longitude']);
          echo("</td><td>");
          echo("<a onclick=\"popUp(event)\" class=\"eliminar\">eliminar</a>");
          echo("</td></tr>\n");
          $last_id = $row['item_id'];
        }
        echo("<tr style='display: none;'><td colspan='5'><form id='new_pdc' action='item.php' method='post'>
          <input type='text' name='m_item_id' value='" . ($last_id + 1) . "' style='' readonly>
          <input type='text' name='m_item_descricao' value='' style=''>
          <input type='text' name='m_localizacao' value='' style=''>
          <select name='m_coordenadas'><option value=''>-- Seleccione o local... --</option>");

        foreach($result2 as $row) {
          echo("<option value='array(" . $row['latitude'] . ", " . $row['longitude'] . ")'>" . $row['nome'] . "</option>");
        }

        echo("</select><input type='submit' value='Submeter'>
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
        cnfdel.children[1].children[0].children[0].value = tr.children[0].innerHTML;
       

        cnfdel.children[0].children[1].innerHTML = tr.children[0].innerHTML;
        cnfdel.style.display = 'block';
      }

      function newAppear(evt) {
        document.getElementById("new_pdc").parentElement.parentElement.style.display = 'flex';
        document.getElementById("that_tbody").scrollTo(0, document.body.scrollHeight);
        document.getElementById("new_pdc").children[1].focus();
      }
    </script>
  </body>
</html>