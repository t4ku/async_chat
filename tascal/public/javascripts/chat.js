$(document).ready(function() {
	var current_time = (new Date).getTime();
	var CONFIG = { debug: false
				 , token:api_key
	             , id: null    
	             , last_message_time: current_time
	             , focus: true 
	             , unread: 0
	             };

	// ユーティリティ
	util = {
	  urlRE: /https?:\/\/([-\w\.]+)+(:\d+)?(\/([^\s]*(\?\S+)?)?)?/g, 

	  // 簡易htmlサニタイズ
	  toStaticHTML: function(inputHtml) {
	    inputHtml = inputHtml.toString();
	    return inputHtml.replace(/&/g, "&amp;")
	                    .replace(/</g, "&lt;")
	                    .replace(/>/g, "&gt;");
	  }, 

	  // 数字の左に0をつめる
	  zeroPad: function (digits, n) {
	    n = n.toString();
	    while (n.length < digits) 
	      n = '0' + n;
	    return n;
	  },

	  // 時刻表示
	  //timeString(new Date); => "19:49"
	  timeString: function (date) {
	    var minutes = date.getMinutes().toString();
	    var hours = date.getHours().toString();
	    return this.zeroPad(2, hours) + ":" + this.zeroPad(2, minutes);
	  },

	  // 空白チェック
	  isBlank: function(text) {
	    var blank = /^\s*$/;
	    return (text.match(blank) !== null);
	  }
	};

	// チャットにメッセージを表示
	function addMessage (from, text, time, _class) {
	  if (text === null)
	    return;

	  if (time == null) {
	    time = new Date();
	  } else if ((time instanceof Date) === false) {
	    time = new Date(time);
	  }

	　　// メッセージ用DOM
	  var messageElement = $(document.createElement("div"));

	  messageElement.addClass("message");
	  if (_class)
	    messageElement.addClass(_class);

	  // テキスト
	  text = util.toStaticHTML(text);

	  // 自分発言用
	  var nick_re = new RegExp(CONFIG.nick);
	  if (nick_re.exec(text))
	    messageElement.addClass("personal");

	  // メッセージ内のURLをリンクか
	  text = text.replace(util.urlRE, '<a target="_blank" href="$&">$&</a>');

	  var content = '  <span class="date">' + util.timeString(time) + '</span>'
	              + '  <span class="nick">' + util.toStaticHTML(from) + '</span>'
	              + '  <span class="msg-text">' + text  + '</span>'
	              + '</span>'
	              ;
	  messageElement.html(content);

	  //$("#messages").append(messageElement);
	  $("#messages").prepend(messageElement);
	}

	var transmission_errors = 0;


	// ロングポール用再帰関数
	function longPoll (data) {
	  if (transmission_errors > 2) {
	    showConnect();
	    return;
	  }


	  if (data && data.messages) {
	    for (var i = 0; i < data.messages.length; i++) {
	      var message = data.messages[i];

	      if (message.timestamp > CONFIG.last_message_time)
	        CONFIG.last_message_time = message.timestamp;

	      switch (message.type) {
	        case "msg":
	          if(!CONFIG.focus){
	            CONFIG.unread++;
	          }
	          addMessage(message.username, message.text, message.timestamp);
	          break;
	      }
	    }
	  }

	  $.ajax({ cache: false
	         , type: "GET"
	         , url:  "/stream/messages.json"
	         , dataType: "json"
	         //, data: first_poll ? {} : { api_key:token,since: CONFIG.last_message_time, id: CONFIG.id }
			 , data: { api_key:CONFIG.token,since: CONFIG.last_message_time, id: CONFIG.id }
	         , error: function () {
	             addMessage("", "long poll error. trying again...", new Date(), "error");
	             transmission_errors += 1;
	             setTimeout(longPoll, 10*1000);
	           }
	         , success: function (data) {
	             transmission_errors = 0;
	             longPoll(data);
	           }
	         });
	}

	// メッセージ送信用関数
	function send(msg) {
	  if (CONFIG.debug === false) {
	    jQuery.post("/stream/message.json",
	 				{api_key:CONFIG.token,id: CONFIG.id, text: msg}, 
					function (data) { 
						console.log(data);
						if (data && data.messages) {
							sent_msg = data.messages[0];
							addMessage(sent_msg.user_id,sent_msg.text,sent_msg.updated_at);
						};
					},
					"json");
	  }
	}

	//Transition the page to the state that prompts the user for a nickname
	function showConnect () {
	}

	//transition the page to the loading screen
	function showLoad () {
	}

	//transition the page to the main chat view, putting the cursor in the textfield
	function showChat (nick) {
	}

	// コールバック
	function onConnect (session) {
	  if (session.error) {
	    alert("error connecting: " + session.error);
	    showConnect();
	    return;
	  }

	  CONFIG.nick = session.nick;
	  CONFIG.id   = session.id;

	  showChat(CONFIG.nick);

	  $(window).bind("blur", function() {
	    CONFIG.focus = false;
	  });

	  $(window).bind("focus", function() {
	    CONFIG.focus = true;
	    CONFIG.unread = 0;
	  });
	}


  // 関数定義終わり、メイン処理

  // チャットテキスト内でのEnterキーr補足
  $("#entry").keypress(function (e) {
    if (e.keyCode != 13 /* Return */) return;
    var msg = $("#entry").attr("value").replace("\n", "");
    if (!util.isBlank(msg)) send(msg);
    $("#entry").attr("value", "");
  });

  // 時間
  setInterval(function () {
    var now = new Date();
    $("#currentTime").text(util.timeString(now));
  }, 1000);

  if (CONFIG.debug) {
    $("#loading").hide();
    $("#connect").hide();
    return;
  }

  // remove fixtures
  $("#log table").remove();

  longPoll();
  showConnect();
});