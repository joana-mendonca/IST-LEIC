<html>
  <head>
    <meta charset="utf-8">
    <title>Anomalias</title>
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

    td:nth-of-type(7n+1) { width: 50px; }

    td:nth-of-type(7n+2) {
      width: 300px;
      text-align: center;
    }

    td:nth-of-type(7n+3) { 
      width: 300px; 
      text-align: center;
    }

    td:nth-of-type(7n+4) {
        width: 160px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        text-align: center;
    }

    td:nth-of-type(7n+5) { width: 200px;  text-align: center; }

    td:nth-of-type(7n+6) { width: 650px;  text-align: center; }

    td:nth-of-type(7n+7) { width: 150px; text-align: center; }

    td:nth-of-type(7n+8) { width: 100px; text-align: center; }



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
      margin: 0;
      padding: 0;
    }

    #new_pdc * {
      font-size: 16px;
      border: none;
      background-color: transparent;
      text-align: center;
    }

    #new_pdc input[name=m_anomalia_id] { width: 50px; }
    #new_pdc input[name=m_zona] { width: 300px; }
    #new_pdc input[name=m_imagem] { width: 300px; }
    #new_pdc input[name=m_lingua] { width: 160px; }
    #new_pdc input[name=m_ts] { width: 200px; }
    #new_pdc input[name=m_anomalia_descricao] { width: 650px; }
    #new_pdc input[name=m_tem_anomalia_redacao] { width: 150px; }
    #new_pdc input[type=submit] { width: 80px}

    h1 {
      text-align: center;
      margin: 12px 0;
    }

    ::-webkit-scrollbar {
      width: 0px;
    }
  </style>
  <body>
    <h1>Anomalias</h1>
    <div id="confirm-delete" style="display: none;">
      <p id="message">De certeza que pretende <b>eliminar</b> a anomalia <span></span>?</p>
      <div id="buttons">
        <form action="anomalia.php" method="get">
          <input type="hidden" name="m_anomalia_id">
          <button type="button" id="no" onclick="document.getElementById('confirm-delete').style.display = 'none'">Cancelar</button>
          <button type="submit" id="ye">Sim</button>
        </form>
      </div>
    </div>
    <?php
      $m_anomalia_id = $_REQUEST['m_anomalia_id'];
      $m_zona = $_REQUEST['m_zona'];
      $m_imagem = $_REQUEST['m_imagem'];
      $m_lingua = $_REQUEST['m_lingua'];
      $m_ts = $_REQUEST['m_ts'];
      $m_anomalia_descricao = $_REQUEST['m_anomalia_descricao'];
      $m_tem_anomalia_redacao = $_REQUEST['m_tem_anomalia_redacao'];

      try {
        $host = "db.ist.utl.pt";
        $user ="ist426015";
        $password = "conacona";
        $dbname = $user;
        
        $db = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        if((isset($m_anomalia_id) && !empty($m_anomalia_id)) &&
          (isset($m_zona) && !empty($m_zona)) &&
          (isset($m_imagem) && !empty($m_imagem)) &&
          (isset($m_anomalia_descricao) && !empty($m_anomalia_descricao)) &&
          (isset($m_tem_anomalia_redacao) && !empty($m_tem_anomalia_redacao)) &&
          (isset($m_lingua) && !empty($m_lingua))) {

          $sql = "INSERT INTO anomalia VALUES (" . $m_anomalia_id . ", '(" . $m_zona . ")', '" . $m_imagem . "' , '" . $m_lingua . "' , '" . date("Y-m-d H:i:s") . "', '" . $m_anomalia_descricao . "' , " . strtoupper($m_tem_anomalia_redacao) . ");";

          $result = $db->prepare($sql);
          $result->execute();
        }
        else if (isset($m_anomalia_id)) {
          $sql = "DELETE FROM anomalia WHERE anomalia_id = " . $m_anomalia_id . ";";

          $result = $db->prepare($sql);
          $result->execute();
        }
      
        $sql = "SELECT * FROM anomalia ORDER BY anomalia_id;";
        $result = $db->prepare($sql);
        $result->execute();

        echo("<table border=\"1\">\n");
        echo("<thead><tr>
          <td id=\"back\"><a href=\"index.html\">Back</a></td>
          <td>Zona</td>
          <td>Imagem</td>
          <td>Lingua</td>
          <td>TS</td>
          <td>Descricao</td>
          <td>Tem Redacao</td>
          <td id=\"insert\"><a onclick=\"newAppear(event)\" class=\"add\">Inserir</a></td>
          </tr></thead>\n<tbody id='that_tbody'>");

        foreach($result as $row) {
          echo("<td class=\"ctr\">");
          echo($row['anomalia_id']);
          echo("</td><td class=\"ctr\">");
          echo($row['zona']);
          echo("</td><td><a href=\"" . $row['imagem'] . "\">");
          echo($row['imagem']);
          echo("</a></td><td>");
          echo($row['lingua']);
          echo("</td><td>");
          echo($row['ts']);
          echo("</td><td>");
          echo($row['anomalia_descricao']);
          echo("</td><td>");
          echo($row['tem_anomalia_redacao']) ? 'true' : 'false';
          echo("</td><td>");
          echo("<a onclick=\"popUp(event)\" class=\"eliminar\">eliminar</a>");
          echo("</td></tr>\n");
          $last_id = $row['anomalia_id'];
        }
        echo("<tr style='display: none;'><td colspan='5'><form id='new_pdc' action='anomalia.php' method='post'>
          <input type='text' name='m_anomalia_id' value='" . ($last_id + 1) . "' style='' readonly>
          <input type='text' name='m_zona' value='' style=''>
          <input type='text' name='m_imagem' value='' style=''>
          <input type='text' name='m_lingua' value='' style=''>
          <input type='text' name='m_ts' value='' style='' readonly>
          <input type='text' name='m_anomalia_descricao' value='' style=''>
          <input type='text' name='m_tem_anomalia_redacao' value='' style=''>
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