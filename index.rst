.. title:: Nutanix Calm IaaS Bootcamp

.. toctree::
  :maxdepth: 2
  :caption: Calm演習準備
  :name: _calm
  :hidden:

  labsetup/labsetup


.. toctree::
  :maxdepth: 2
  :caption: LinuxによるIaaSサービス
  :name: _calm_linux_track
  :hidden:

  calm_linux_track/calm_iaas_linux/calm_iaas_linux

.. toctree::
  :maxdepth: 2
  :caption: WindowsによるIaaSサービス
  :name: _calm_windows_track
  :hidden:

  calm_windows_track/calm_iaas_windows/calm_iaas_windows

.. toctree::
  :maxdepth: 2
  :caption: 追加の演習
  :name: _additional_calm_labs
  :hidden:

  calm_escript/calm_escript

.. toctree::
  :maxdepth: 2
  :caption: 任意の演習
  :name: _optional_labs
  :hidden:

  calm_enable/calm_enable

.. toctree::
  :maxdepth: 2
  :caption: Appendix
  :name: _appendix
  :hidden:

  appendix/glossary

.. _getting_started:

---------------
はじめに
---------------

Nutanix Calm IaaS Bootcampへようこそ!

このワークブックは、Nutanix Calmと多くの一般的な管理タスクを紹介するインストラクタ主導のセッション向けに作成されました。

最新情報
++++++++++

- ワークショップを以下のソフトウェアバージョンに更新しました。:
    - AOS 5.16.x & PC 5.17.x

アジェンダ
++++++

- Nutanix Calm メインの演習
    - Calm: ラボセットアップ
    - Calm: Linux IaaSサービスの構築
    - Calm: Windows IaaSサービスの構築

- 追加の演習
    - Calm: DSL

- 任意の演習
    - Calm: 有効化
    
- Appendix
    - 用語集 

イントロダクション
+++++++++++++

- お名前
- Nutanix経験

初期セットアップ
+++++++++++++

- ご使用される **Passwords** のメモを取ってください
- 仮想デスクトップにログインしてください。

クラスタの割り当て
++++++++++++++++++

講師は参加者に自分の割り当てられたクラスターを伝えます。 

.. note::
  
  もしこれらがシングルノードクラスタ(SNC)であれば、ネットワークの部分に注意を払ってください。SNCは "通常の "3ノード/4ノードクラスタとは全く異なるセットアップと構成になっています。

環境の詳細
+++++++++++++++++++

Nutanixワークショップは、Nutanix Hosted POC環境を利用します。演習を完了するために必要なイメージ、ネットワーク、VMは事前に構築されています。

ネットワーク
..........

Hosted POC クラスタは 以下の命名規則に従い命名されています:

- **Cluster Name** - POC\ *XYZ*
- **Subnet** - 10.**21**.\ *XYZ*\ .0
- **Cluster IP** - 10.**21**.\ *XYZ*\ .37

例:

- **Cluster Name** - POC055
- **Subnet** - 10.21.55.0
- **Cluster IP** - 10.21.55.37

環境内には、* XYZ *をサブネットの正しいオクテットに置き換える必要があるVMが存在しています。たとえば：

.. list-table::
   :widths: 25 75
   :header-rows: 1

   * - IP Address
     - 説明
   * - 10.21.\ *XYZ*\ .37
     - Nutanix Cluster 仮想IP
   * - 10.21.\ *XYZ*\ .39
     - **PC** VM IP, Prism Central
   * - 10.21.\ *XYZ*\ .40
     - **DC** VM IP, NTNXLAB.local ドメインコントローラー

各クラスタは、VMに使用できる2つのVLANで構成されています。

.. list-table::
  :widths: 25 25 10 40
  :header-rows: 1

  * - Network Name
    - Address
    - VLAN
    - DHCP Scope
  * - Primary
    - 10.21.\ *XYZ*\ .1/25
    - 0
    - 10.21.\ *XYZ*\ .50-10.21.\ *XYZ*\ .124
  * - Secondary
    - 10.21.\ *XYZ*\ .129/25
    - *XYZ1*
    - 10.21.\ *XYZ*\ .132-10.21.\ *XYZ*\ .253

認証情報
...........

.. note::

  <クラスタ・パスワード>は各クラスタに固有であり、講師によって提供されます。

.. list-table::
   :widths: 25 35 40
   :header-rows: 1

   * - ノード
     - ユーザ名
     - パスワード
   * - Prism Element
     - admin
     - *<Cluster Password>*
   * - Prism Central
     - admin
     - *<Cluster Password>*
   * - Controller VM
     - nutanix
     - *<Cluster Password>*
   * - Prism Central VM
     - nutanix
     - *<Cluster Password>*

各クラスタには専用のドメインコントローラーVM、DCが存在し、ntnxlab.localドメインにActive Directoryサービスを提供します。ドメインには、次のユーザーとグループが格納されています。

.. list-table::
   :widths: 25 35 40
   :header-rows: 1

   * - グループ
     - ユーザ名
     - パスワード
   * - Administrators
     - Administrator
     - nutanix/4u
   * - SSP Admins
     - adminuser01-adminuser25
     - nutanix/4u
   * - SSP Developers
     - devuser01-devuser25
     - nutanix/4u
   * - SSP Consumers
     - consumer01-consumer25
     - nutanix/4u
   * - SSP Operators
     - operator01-operator25
     - nutanix/4u
   * - SSP Custom
     - custom01-custom25
     - nutanix/4u
   * - Bootcamp Users
     - user01-user25
     - nutanix/4u

アクセス手順
+++++++++++++++++++

Nutanix Hosted POC 環境には以下の方法で接続できます。:

ユーザ名、パスワード
...........................

PHX クラスタ:
**Username:** PHX-POCxxx-User01 〜 PHX-POCxxx-User20, **Password:** *<講師から提供>*

RTP クラスタ:
**Username:** RTP-POCxxx-User01 〜 RTP-POCxxx-User20, **Password:** *<講師から提供>*

Frame VDI
.........

ログイン: https://frame.nutanix.com/x/labs

上記 **Username**, **Password** を入力

Parallels VDI
.................

PHX クラスタ: https://xld-uswest1.nutanix.com

RTP クラスタ: https://xld-useast1.nutanix.com

上記 **Username**, **Password** を入力


Nutanixバージョン情報
++++++++++++++++++++

- **AHV Version** - AHV 20190916.158 (AOS 5.16+)
- **AOS Version** - 5.16.1.2
- **PC Version** - 5.17.0.3
