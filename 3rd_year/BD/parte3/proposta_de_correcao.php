<html>
  <head>
    <meta charset="utf-8">
    <title>Propostas de Correção</title>
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
      width: 350px;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    td:nth-of-type(5n+3) { width: 200px; }

    td:nth-of-type(5n+4) { width: calc(100% - 705px); }

    td:nth-of-type(5n+5) { width: 105px; }

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

    form {
      width: 100%;
      display: flex;
      justify-content: center;
    }

    form input.m_texto {
      padding: 1px 0 0 4px;
      border: none;
      height: 25px;
      font-size: 16px;
      background-color: transparent;
      flex-grow: 2;
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

    #new_pdc input[name=m_nro] { width: 50px; text-align: center; }
    #new_pdc select[name=m_pdc_email] { width: 350px; margin-left: -3px; }
    #new_pdc input[name=m_data_hora] { width: 200px; }
    #new_pdc input[name=m_texto] { flex-grow: 2; padding-left: 4px; margin-left: 2px; }
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
    <h1>Propostas de Correção</h1>
    <div id="confirm-delete" style="display: none;">
      <p id="message">De certeza que pretende <b>eliminar</b> a proposta número <span></span>?</p>
      <div id="buttons">
        <form action="proposta_de_correcao.php" method="post">
          <input type="hidden" name="m_nro">
          <input type="hidden" name="m_pdc_email">
          <button type="button" id="no" onclick="document.getElementById('confirm-delete').style.display = 'none'">Cancelar</button>
          <button type="submit" id="ye">Sim</button>
        </form>
      </div>
    </div>
    <?php
      ini_set("log_errors", 1);
      ini_set("display_startup_errors", 1);
      ini_set("error_log", "C:\\Users\\fijoz\\OneDrive\\uni\\2019-2020\\1-sem\\bd\\parte3\\php-log.txt");

      $m_nro = $_REQUEST['m_nro'];
      $m_pdc_email = $_REQUEST['m_pdc_email'];
      $m_data_hora = $_REQUEST['m_data_hora'];
      $m_texto = $_REQUEST['m_texto'];

      try {
        $last_id = 0;
        $host = "db.ist.utl.pt";
        $user ="ist426015";
        $password = "conacona";
        $dbname = $user;

        $db = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        if (isset($m_nro) && isset($m_pdc_email)) {
          /* it was an edit */
          if (isset($m_texto) && !isset($m_data_hora))
            $sql = "UPDATE proposta_de_correcao SET texto = '" . $m_texto . "' WHERE nro = " . $m_nro . " AND pdc_email = '" . $m_pdc_email . "';";

          /* it was a create */
          if (isset($m_texto) && isset($m_data_hora)) {
            $sql = "INSERT INTO proposta_de_correcao VALUES (" . $m_nro . ", '" . $m_pdc_email . "', '" . date("Y-m-d H:i:s") . "', '" . $m_texto . "');";
          }

          /* it was a delete */
          else
            $sql = "DELETE FROM proposta_de_correcao WHERE nro = " . $m_nro . " AND pdc_email = '" . $m_pdc_email . "';";

          $result = $db->prepare($sql);
          $result->execute();
        }
      
        $sql = "SELECT * FROM proposta_de_correcao ORDER BY nro;";
        $result = $db->prepare($sql);
        $result->execute();

        $sql2 = "SELECT * FROM utilizador_qualificado ORDER BY email;";
        $result2 = $db->prepare($sql2);
        $result2->execute();

        echo("<table border=\"1\">\n");
        echo("<thead><tr>
          <td id=\"back\"><a href=\"index.html\">Back</a></td>
          <td>E-mail</td>
          <td>Data/Hora</td>
          <td>Correção</td>
          <td id=\"insert\"><a onclick=\"newAppear(event)\">Insert</a></td>
          </tr></thead>\n<tbody id='that_tbody'>");

        foreach($result as $row) {
          echo("<tr><td class=\"ctr\">");
          echo($row['nro']);
          echo("</td><td>");
          echo($row['pdc_email']);
          echo("</td><td class=\"ctr\">");
          echo($row['data_hora']);
          echo("</td><td>");
          echo("<span class='thisspan'>" . $row['texto'] . "</span>");
          echo("<form action='proposta_de_correcao.php' method='post' style='display: none'>
            <input type='hidden' name='m_nro' value='" . $row["nro"] . "'>
            <input type='hidden' name='m_pdc_email' value='" . $row["pdc_email"] . "'>
            <input type='text' name='m_texto' class='m_texto' value='" . $row['texto'] . "'>
            <input type='submit' value='OK'>
            </form>");
          echo("</td><td>");
          echo("<a onclick=\"editPDC(event)\" class=\"editar\">editar</a> <a onclick=\"popUp(event)\" class=\"eliminar\">eliminar</a>");
          echo("</td></tr>\n");
          $last_id = $row['nro'];
        }
        echo("<tr style='display: none;'><td colspan='5'><form id='new_pdc' action='proposta_de_correcao.php' method='post'>
          <input type='text' name='m_nro' value='" . strval($last_id + 1) . "' style='' readonly>
          <select name='m_pdc_email'>");

        foreach($result2 as $row) {
          echo("<option value='" . $row['email'] . "'>" . $row['email'] . "</option>");
        }

        echo("</select>
          <input type='text' name='m_data_hora' value='' style='' readonly>
          <input type='text' name='m_texto' value='' style=''>
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
      if ( window.history.replaceState ) {
        window.history.replaceState( null, null, window.location.href );
      }
      function editPDC(evt) {
        frm = evt.srcElement.parentElement.parentElement.children[3].children;

        frm[0].style.display = 'none';
        frm[1].style.display = 'flex';
        frm[1][2].focus();
        frm[1][2].selectionStart = frm[1][2].selectionEnd = 10000;
      }

      function popUp(evt) {
        cnfdel = document.getElementById("confirm-delete");
        frm = evt.srcElement.parentElement.parentElement;
        cnfdel.children[1].children[0].children[0].value = frm.children[0].innerHTML;
        cnfdel.children[1].children[0].children[1].value = frm.children[1].innerHTML;

        cnfdel.children[0].children[1].innerHTML = frm.children[0].innerHTML;
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