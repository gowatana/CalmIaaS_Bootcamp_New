.. _calm_runbook:

-----------------------------------------
Calm: Runbook
-----------------------------------------

概要
++++++++

:ref:`calm_iaas_linux` と :ref:`calm_iaas_windows` の演習では、BashやPowerShellスクリプトを利用してアプリケーションのデプロイを自動化する方法を検討しました。シェルスクリプトは強力で汎用性がありますが、スクリプトをローカルにコピーして実行するためのエンドポイントVMをデプロイする必要があります。また、前の演習で行ったeScriptはブループリントによる仮想マシンの作成なしにRESTfulサービスへのAPI呼び出しなどをCalmから行うものでしたが、やはりPrism Centralを"既存の仮想マシン"としてブループリントに取り込む必要がありました。ブループリントによる仮想マシンの作成や既存仮想マシンの取り込みなしにIT運用タスクを自動実行する汎用的な仕組みはないでしょうか？あります、Calm 3.0でリリースされたRunbook(指示書)は汎用的なIT運用タスクを自動化し、ブループリントと同じくプロジェクトユーザに対して公開してセルフサービスで実行を行わせることが可能です。

このラボでは、Calm Runbookを使用して、WindowsサーバのIaaSサービスの章で作成したWindows Server OSのアップデートを行うRunbookを作成し、マーケットプレイスに公開します。

エンドポイントの作成
+++++++++

エンドポイントはシェルスクリプト、Powershell、REST APIを実行する仮想マシンです。Runbookは設定されたエンドポイントに接続し、定義されたアクションを実行します。

#. **Prism Central** で、 :fa:`bars` **> サービス > Calm** を選択します。

#. 左側のツールバーの **Endpoints** を選択して、Endpointを表示および管理します。

#. **+エンドポイントを作成** を選択します。

#. 以下の項目を記入し、 **保存** をクリックします。

   - **名前** - *あなたのイニシャル*-Windows
   - **説明** - 任意
   - **プロジェクト** - *あなたのイニシャル*-Project
   - **タイプ** - Windows
   - **ターゲットの種類** - 仮想マシン
   - **アカウント＊＊ - NTNX_LOCAL_AZ
   - **フィルタ条件** - **名前** , **開始** , **あなたのイニシャル-Win2016** を入力し、 **追加** をクリック、あなたのWindows仮想マシンのうち、タイムスタンプが古い方を選択
   - **認証情報**
      - **ユーザ名** - Administrator
      - **秘密のタイプ** - パスワード
      - **パスワード** - Nutanix/4u

   .. figure:: images/endpoint-1.png
   .. figure:: images/endpoint-2.png

Runbookの作成
+++++++++

Runbookは自動化したいIT運用タスクを定義するものです。インタフェースはシンプルながらも分岐やループを用いて複雑な運用ロジックを定型化することが可能です。

#. 左側のツールバーの **Runbooks** を選択して、CalmのRunbookを表示および管理します。



#. `こちら <https://github.com/shocnt/CalmIaaS_Bootcamp/raw/master/calm_escript/PC-EScript.json>`_ からテンプレートとなるブループリントをローカルマシンにダウンロードします。(ブラウザの機能においてファイルを別名ダウンロードしてください。)

#. **ブループリントのアップロード** をクリックし、ダウンロードしたjsonファイル(PC-EScript.json)を選択します。

#. 以下の項目を記入します。

   - **ブループリント名** - *あなたのイニシャル*-EScript
   - **プロジェクト** - *あなたのイニシャル*-Project

#. ブループリントの上部にあるツールバーから、 **認証情報** をクリックします。

#. **認証情報** :fa:`plus-circle` をクリックし、以下情報を入力します。

   - **認証情報名** - PC_Creds
   - **ユーザ名** - admin
   - **秘密のタイプ** - Password
   - **パスワード** - *あなたのPrism Centralのadminパスワード*

   .. figure:: images/credentials.png

#. **保存** をクリックしてから **戻る** をクリックします。エラーや警告が表示されないことを確認します。

Existing Machineサービスの使用
+++++++++++++++++++++++++++++++

#. 左上の **サービス** において、 "PC"というサービスをクリックします。

   .. figure:: images/app_service.png

#. **仮想マシン** タブで、以下のフィールドを入力します。

   - **サービス名** - PC
   - **名前** - PrismCentral
   - **クラウド** - 既存のマシン
   - **オペレーティングシステム** - Linux
   - **IP アドレス** - localhost
   - **作成時ログインのチェック** - **チェックしない**
   
   .. figure:: images/app_vm.png

   上記構成の中には、新しく出てきた概念がいくつかあります。

   - **アカウント** - 新しいVMをNutanixやパブリッククラウドプロバイダ上に作成するのではなく、既存のマシンにおいてスクリプト実行したり、APIコールを行うことを選択しています。入力に必要なのはマシンのIPアドレスだけで、この例ではPrism Centralです。ユースケースによっては、Ansible TowerやEra Serverのようなものを既存のマシンとして指定することもできます。

   - **IP アドレス** - ここでは、Prism Centralに対してAPIコールを行う予定であり、CalmはPrism Centralで直接実行されるので、IPとしてlocalhostを入力します。Ansible TowerやEraに対して自動化を行う場合は、Localhostではなく、Ansible TowerやEra ServerのIPアドレスをこのフィールドに入力する必要があります。IP アドレスは変数で定義することもできます。

   - **作成時ログインのチェック** - 仮想マシン作成後、ログイン確認を行うタスクでｓが、EScriptタスクはCalm内で直接実行されるので、問題のサービスにSSH接続する必要はありません。その代わりに、EScriptコード内で直接認証情報を使用してREST API呼び出しを認証します。

#. **保存** をクリックし、エラーや警告が表示されないことを確認します。

RESTList カスタムアクション
++++++++++++++++++++++

この演習では、アプリケーションがPrism Centralに対してREST API呼び出しを行うためのカスタムアクションを作成します。具体的には、POST /list呼び出しで、リストされるエンティティ（種類）（アプリ、ホスト、クラスタ、ロールなど）を実行時に変数で定義します。そして、この呼び出しの結果が出力されます。

#. **アプリケーションプロファイル** において、 **Default** のアプリケーションプロファイルを選択します。

   .. figure:: images/addaction.png

#. **アクション** の隣にある :fa:`plus-circle` を選択すると、新しいカスタムアクションが追加されます。

#. 右側の **Configuration Pane** で、 **RESTList** というアクション名を付け、"変数"の右の :fa:`plus-circle` を選択して1つの変数を追加します。

   - **名前** - kind
   - **データのタイプ** - String
   - **値** - apps
   - 右上の走る人のアイコンを青に変更して **ランタイム変更可能** を選択してください。

   .. figure:: images/restlist.png

   後でカスタムアクションを実行すると、Calmはユーザーに入力を求めます。 **kind** はデフォルト値(apps)があらかじめ入力されていますが、スクリプトアクションを実行する前に変更することができます。

#. EScriptタスクを **RESTList** カスタムアクションに追加するには、画面中央の"PC"サービスにおいて **+タスク** ボタンをクリックします。 以下のフィールドを入力します。

   - **タスク名** - RuntimePost
   - **タイプ** - 実行
   - **スクリプトタイプ** - EScript
   - **スクリプト** - *以下のpythonコードを貼り付けます*

   .. code-block:: python

     # Set the credentials
     pc_user = '@@{PC_Creds.username}@@'
     pc_pass = '@@{PC_Creds.secret}@@'

     # Set the headers, url, and payload
     headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}
     url     = "https://@@{address}@@:9440/api/nutanix/v3/@@{kind}@@/list"
     payload = {}

     # Make the request
     resp = urlreq(url, verb='POST', auth='BASIC', user=pc_user, passwd=pc_pass, params=json.dumps(payload), headers=headers)

     # If the request went through correctly, print it out.  Otherwise error out, and print the response.
     if resp.ok:
      print json.dumps(json.loads(resp.content), indent=4)
      exit(0)
     else:
      print "Post request failed", resp.content
      exit(1)

   .. figure:: images/runtime_post.png

   このタスクには、新しくて面白い機能がいくつかあります。

   "スクリプトタイプ"としてShell、EScript、Powershellが選択可能です。ShellやPowershellを選択すると、"サービス"として指定した可能マシンにおいてシェルスクリプトやPowershellの実行が可能です。ここではEScriptを選択しているため、Calm内にあるpythonのサンドボックス環境においてpythonスクリプトが実行されます。
   
   Calm UIにはCredentialドロップダウンがなく、代わりに先ほど指定したPC_Credsのユーザー名(@@{PC_Creds.username}@@)とパスワード(@@{PC_Creds.secret}@@)と同じPython変数を設定していることに注意してください。他のAPIは認証を必要としない場合や、URLの一部としてAPIキーを提供する必要がある場合があります。

   また、urlreqモジュールが使用されていることがわかります。レスポンスが期待通りに返された場合、JSONレスポンスはフォーマットされて出力され、そうでなければ対応するエラーメッセージが出力されます。

   スクリプト記述ウィンドウの右下にある"テストスクリプト"によって、ブループリントを開発しながらスクリプトの実行テストをすることが可能です。

#. **保存** をクリックし、エラーや警告が表示されないことを確認します。

GetDefaultSubnet カスタム アクション
++++++++++++++++++++++++++++++
 
この演習では、別のREST API呼び出しを行うためのカスタムアクションを追加で作成します。この呼び出しは、このPrism Centralインスタンス上の **プロジェクト** のリストを返します。 次に、このAPIコールの出力を解析して、実行中のアプリケーションが属するプロジェクトに設定されたデフォルトのサブネットのUUIDを取得します。このUUIDはCalm変数として設定され、ブループリント内の他の場所で再利用できるようになります。次に、別のREST APIコールを行い、デフォルトサブネットをGETします（この新しく設定された変数を利用します）。
 
#. **PC** サービスを選択します。右側の **設定ペイン** で、 **サービス** タブを選択します。"変数"の右の :fa:`plus-circle` を選択して1つの変数を追加します。他のフィールドはすべて空白のままにして、 **SUBNET** という名前の変数を追加します。
 
   - **名前** - SUBNET
   - **データのタイプ** - String
   - **値** - 空白のままとします
 
   .. figure:: images/subnet_variable.png
 
#. **アプリケーションプロファイル > Default** セクションにおいて、 **アクション** の隣の :fa:`plus-circle` を選択し、新規のアクションを追加します。
 
#. アクション名を **GetDefaultSubnet** とします。
 
   .. figure:: images/get_default_subnet.png
 
#. EScriptタスクを **GetDefaultSubnet** カスタムアクションに追加するには、画面中央の"PC"サービスにおいて **+タスク** ボタンをクリックします。 以下のフィールドを入力します。
 
   - **タスク名** - GetSubnetUUID
   - **タイプ** - 変数の設定
   - **スクリプトタイプ** - EScript
   - **スクリプト** - *以下のpythonコードを貼り付けます*
   - **出力** - SUBNET
 
   .. code-block:: python
 
     # Get the JWT
     jwt = '@@{calm_jwt}@@'
 
     # Set the headers, url, and payload
     headers = {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer {}'.format(jwt)}
     url     = "https://@@{address}@@:9440/api/nutanix/v3/projects/list"
     payload = {}
 
     # Make the request
     resp = urlreq(url, verb='POST', params=json.dumps(payload), headers=headers, verify=False)
 
     # If the request went through correctly
     if resp.ok:
 
       # Cycle through the project "entities", and check if its name matches the current project
       for project in json.loads(resp.content)['entities']:
           if project['spec']['name'] == '@@{calm_project_name}@@':
  
             # If there's a default subnet reference, print UUID to set variable and exit success, otherwise error out
             if 'uuid' in project['status']['resources']['default_subnet_reference']:
               print "SUBNET={0}".format(project['status']['resources']['default_subnet_reference']['uuid'])
               exit (0)
             else:
               print "The '@@{calm_project_name}@@' project does not have a default subnet set."
               exit(1)
  
       # If we've reached this point in the code, none of our projects matched the calm_project_name macro
       print "The '@@{calm_project_name}@@' project does not match any of our /projects/list api call."
       print json.dumps(json.loads(resp.content), indent=4)
       exit(0)
 
     # In case the request returns an error
     else:
       print "Post clusters/list request failed", resp.content
       exit(1)
 
   .. figure:: images/get_subnet_uuid.png
 
   **RESTList** タスクと **GetDefaultSubnet** タスクの間には、2つの重要な違いがあります。
   
   最初の違いは **変数の設定** タスクタイプの使用です。 **print "SUBNET={0}"** 行に注意してください。Calmは **変数=値** という形式で出力を解析し、その値に等しい変数を設定します。 この例では、 **SUBNET** という変数が、初期APIコールレスポンスの "default_subnet_reference"フィールドのUUIDと等しいことを出力しています。スクリプト本体の下にある、 **出力** フィールドに、変数を適切に設定するために Calmの変数名を正しく貼り付ける必要があります。この変数は、グローバル変数もしくは、 **PC** サービスのローカル変数として、Calmのブループリントにてすでに定義されている必要があります。
 
   2つ目の違いは、 **PC_Cred** クレデンシャルを使用して、Prism Centralに対するAPIコールを認証していないことです。代わりに、組み込みの **calm_jwt** マクロによって提供される `JSON Web Token <https://en.wikipedia.org/wiki/JSON_Web_Token>`_ を使用しています。
 
#. **+タスク** ボタンを再度クリックして、 **GetDefaultSubnet** カスタムアクションに2つ目のタスクを追加します。 以下のフィールドを入力します。
 
   - **タスク名** - GetSubnetInfo
   - **タイプ** - 実行
   - **スクリプトタイプ** - EScript
   - **スクリプト** - *以下のpythonコードを貼り付けます*
 
   .. code-block:: python
 
     # Get the JWT
     jwt = '@@{calm_jwt}@@'
     
     # Set the headers, url, and payload
     headers = {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer {}'.format(jwt)}
     url     = "https://@@{address}@@:9440/api/nutanix/v3/subnets/@@{SUBNET}@@"
     payload = {}
     
     # Make the request
     resp = urlreq(url, verb='GET', params=json.dumps(payload), headers=headers, verify=False)
     
     # If the request went through correctly, print it out.  Otherwise error out, and print the response.
     if resp.ok:
       print json.dumps(json.loads(resp.content), indent=4)
       exit(0)
     else:
       print "Get request failed", resp.content
       exit(1)
 
   このタスクでは、GET APIコールと前のタスクで返された **SUBNET** UUID変数を使用して、デフォルトのサブネットの詳細を動的に返します。 
 
   .. figure:: images/get_subnet_info.png
 
#. **保存** をクリックし、エラーや警告が表示されないことを確認します。

カスタムアクションの実行
++++++++++++++++++++++++++

#. ブループリントを起動します。画面右上の"起動"をクリックします。以下情報を入力し、"作成"をクリックします。この場合、新たに仮想マシンが起動されないので、作成タスクはすぐに完了するはずです。

   - **アプリケーションの名前** - *あなたのイニシャル*-RestCalls

#. アプリケーションが **実行中** の状態になったら、 **管理** タブを選択します。

   .. figure:: images/app_create.png

#. 次に、 **RESTList** アクションの :fa:`play` アイコンをクリックして、 **RESTList** アクションを実行します。新しいウィンドウが表示され、 **kind** 変数とデフォルトの **apps** 値が表示されます。 **実行** をクリックします。

   .. figure:: images/apps_run.png

#. 右側のペインの出力で、 **RuntimePost** タスクを最大化し、API出力を表示します。 :fa:`eye` アイコンをクリックすることで、出力ペインを切り替えることができます。出力/スクリプトウィンドウを最大化すると、確認しやすくなります。予想通り、スクリプトは、Calmで起動した各アプリケーションや仮想マシンの情報を記述した配列を持つJSONボディを返します。

   .. figure:: images/apps_run2.png

#. **RESTList** アクションを再度実行し、値を **images** 、 **clusters** 、 **hosts** 、 **vms** などの別のPrism Central APIエンティティに変更します。それぞれの情報が取得出来ていることを確認します。

#. 最後に、 **GetDefaultSubnet** アクションを実行します。 **GetSubnetUUID** タスクと **GetSubnetInfo** タスクの両方を展開し、各タスクの出力を確認します。デフォルトのサブネットの名前とVLAN IDは何ですか？

   .. figure:: images/GetDefaultSubnet.png

   .. figure:: images/GetDefaultSubnet2.png

タスクライブラリへの公開
++++++++++++++++++++++++++++++

共通APIコール、共通サービス向けのパッケージインストール、ドメイン結合などのタスクは、複数のブループリントに幅広く適用できます。これらのタスクは、サードパーティのツールを利用したり、手動でスクリプトをコピーして貼り付けたりすることなく、Calmのコード再利用のための中央リポジトリであるタスクライブラリに公開することで使用することができます。

#. ブループリントエディタで **あなたのイニシャル-EScript** ブループリントを開きます。

#. **アプリケーションプロファイル** で、 **RESTList** アクションを選択します。

#. 画面中央の"PC"サービスにおいて、 **RuntimePost** タスクを選択します。

#. 画面右側の設定ペインにおいて、 **ライブラリに公開** をクリックします。

#. **タスクを公開** ウィンドウで、以下の変更を行います。

   - **名前** - *あなたのイニシャル* Prism Central Runtime List
   - **address** - **Prism_Central_IP** に変更

   .. figure:: images/publish_task.png

#. **適用** をクリックして、元の **address** マクロがスクリプトウィンドウの **Prism_Central_IP** に置き換えられていることに注意してください。マクロ名を置き換えることで、タスクの移植性を高めるために、より一般的にすることができます。

#. **公開** をクリックします。

#. サイドバーの **Library** を開きます。公開されているタスクを選択します。デフォルトでは、そのタスクは元々公開されていたプロジェクトで利用できますが、タスクを共有するプロジェクトを追加で指定することもできます。

#. `NutanixのGithub <https://github.com/nutanix/blueprints/tree/master/library/task-library>`_ では、再利用可能な200以上のタスクがありますので、確認してみて下さい。

------

終わりに
+++++++++

**Nutanix Calm** について知っておくべき重要なことは何ですか？

- タスクライブラリは、一般的に使用される操作を一度登録し、何度も再利用することを可能にします。Nutanixが提供する一般的なタスクからサービスオブジェクト全体に至るまで、より多くのオブジェクトがタスクライブラリに統合されていきます。

- 今回ご紹介したEScriptの他にも、HTTPタスクがあり、EScriptによるAPIコール送信をより簡単に実装することができます。

- Nutanix Calmは、BashやPowershellスクリプトを使用できることに加えて、サンドボックス化されたPythonインタプリタであるEScriptを使用して、アプリケーションのライフサイクル管理を提供することができます。

- EScriptタスクは、リモートマシン上で実行されるのではなく、Calmエンジン内で直接実行されます。

- Shell、Powershell、および EScriptタスクはすべて、スクリプト出力に基づいて変数を設定するために利用できます。その変数は、ブループリントの他の部分で使用することができます。

- タスクライブラリでは、一般的に使用されるタスクを中央のリポジトリに公開することができ、プロジェクトやブループリント間でスクリプトを共有することができます。

.. |proj-icon| image:: ../images/projects_icon.png
.. |mktmgr-icon| image:: ../images/marketplacemanager_icon.png
.. |mkt-icon| image:: ../images/marketplace_icon.png
.. |bp-icon| image:: ../images/blueprints_icon.png
.. |blueprints| image:: images/blueprints.png
.. |applications| image:: images/blueprints.png
