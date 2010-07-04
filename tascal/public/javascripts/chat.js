$(document).ready(function() {
	var current_time = (new Date).getTime();
	var CONFIG = { debug: false
				 , token:api_key
	             , id: null    // set in onConnect
	             , last_message_time: current_time
	             , focus: true //event listeners bound in onConnect
	             , unread: 0 //updated in the message-processing loop
	             };

	var users = [];

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
	    // if the time is null or undefined, use the current time.
	    time = new Date();
	  } else if ((time instanceof Date) === false) {
	    // if it's a timestamp, interpret it
	    time = new Date(time);
	  }

	　　// メッセージ用DOM
	  var messageElement = $(document.createElement("div"));

	  messageElement.addClass("message");
	  if (_class)
	    messageElement.addClass(_class);

	  // テキスト
	  text = util.toStaticHTML(text);

	  // If the current user said this, add a special css class
	  var nick_re = new RegExp(CONFIG.nick);
	  if (nick_re.exec(text))
	    messageElement.addClass("personal");

	  // replace URLs with links
	  text = text.replace(util.urlRE, '<a target="_blank" href="$&">$&</a>');

	  var content = '  <span class="date">' + util.timeString(time) + '</span>'
	              + '  <span class="nick">' + util.toStaticHTML(from) + '</span>'
	              + '  <span class="msg-text">' + text  + '</span>'
	              + '</span>'
	              ;
	  messageElement.html(content);

	  //the log is the stream that we view
	  //$("#messages").append(messageElement);
	  $("#messages").prepend(messageElement);

	  //always view the most recent message when it is added
	}

	var transmission_errors = 0;
	var first_poll = true;


	//process updates if we have any, request updates from the server,
	// and call again with response. the last part is like recursion except the call
	// is being made from the response handler, and not at some point during the
	// function's execution.
	function longPoll (data) {
	  if (transmission_errors > 2) {
	    showConnect();
	    return;
	  }

	  //process any updates we may have
	  //data will be null on the first call of longPoll
	  if (data && data.messages) {
	    for (var i = 0; i < data.messages.length; i++) {
	      var message = data.messages[i];

	      //track oldest message so we only request newer messages from server
	      if (message.timestamp > CONFIG.last_message_time)
	        CONFIG.last_message_time = message.timestamp;

	      //dispatch new messages to their appropriate handlers
	      switch (message.type) {
	        case "msg":
	          if(!CONFIG.focus){
	            CONFIG.unread++;
	          }
	          addMessage(message.username, message.text, message.timestamp);
	          break;
	      }
	    }

	    //only after the first request for messages do we want to show who is here
	    if (first_poll) {
	      first_poll = false;
	    }
	  }

	  //make another request
	  $.ajax({ cache: false
	         , type: "GET"
	         , url:  "/stream/messages.json"
	         , dataType: "json"
	         //, data: first_poll ? {} : { api_key:token,since: CONFIG.last_message_time, id: CONFIG.id }
			 , data: { api_key:CONFIG.token,since: CONFIG.last_message_time, id: CONFIG.id }
	         , error: function () {
	             addMessage("", "long poll error. trying again...", new Date(), "error");
	             transmission_errors += 1;
	             //don't flood the servers on error, wait 10 seconds before retrying
	             setTimeout(longPoll, 10*1000);
	           }
	         , success: function (data) {
	             transmission_errors = 0;
	             //if everything went well, begin another request immediately
	             //the server will take a long time to respond
	             //how long? well, it will wait until there is another message
	             //and then it will return it to us and close the connection.
	             //since the connection is closed when we get data, we longPoll again
	             longPoll(data);
	           }
	         });
	}

	//submit a new message to the server
	function send(msg) {
	  if (CONFIG.debug === false) {
	    // XXX should be POST
	    // XXX should add to messages immediately
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
	  $("#connect").show();
	  $("#loading").hide();
	  $("#toolbar").hide();
	  $("#nickInput").focus();
	}

	//transition the page to the loading screen
	function showLoad () {
	  $("#connect").hide();
	  $("#loading").show();
	  $("#toolbar").hide();
	}

	//transition the page to the main chat view, putting the cursor in the textfield
	function showChat (nick) {
	  $("#toolbar").show();
	  $("#entry").focus();

	  $("#connect").hide();
	  $("#loading").hide();

	}

	//handle the server's response to our nickname and join request
	function onConnect (session) {
	  if (session.error) {
	    alert("error connecting: " + session.error);
	    showConnect();
	    return;
	  }

	  CONFIG.nick = session.nick;
	  CONFIG.id   = session.id;

	  //update the UI to show the chat
	  showChat(CONFIG.nick);

	  //listen for browser events so we know to update the document title
	  $(window).bind("blur", function() {
	    CONFIG.focus = false;
	  });

	  $(window).bind("focus", function() {
	    CONFIG.focus = true;
	    CONFIG.unread = 0;
	  });
	}

	//add a list of present chat members to the stream
	function showUsers () {
	  var users_string = users.length > 0 ? users.join(", ") : "(none)";
	  addMessage("users:", users_string, new Date(), "notice");
	  return false;
	}

  //submit new messages when the user hits enter if the message isnt blank
  $("#entry").keypress(function (e) {
    if (e.keyCode != 13 /* Return */) return;
    var msg = $("#entry").attr("value").replace("\n", "");
    if (!util.isBlank(msg)) send(msg);
    $("#entry").attr("value", ""); // clear the entry field.
  });

  $("#usersLink").click(showUsers);

  //try joining the chat when the user clicks the connect button
  $("#connectButton").click(function () {
    //lock the UI while waiting for a response
    showLoad();
    var nick = $("#nickInput").attr("value");

    //dont bother the backend if we fail easy validations
    if (nick.length > 50) {
      alert("Nick too long. 50 character max.");
      showConnect();
      return false;
    }

    //more validations
    if (/[^\w_\-^!]/.exec(nick)) {
      alert("Bad character in nick. Can only have letters, numbers, and '_', '-', '^', '!'");
      showConnect();
      return false;
    }

    //make the actual join request to the server
    $.ajax({ cache: false
           , type: "GET" // XXX should be POST
           , dataType: "json"
           , url: "/join"
           , data: { nick: nick }
           , error: function () {
               alert("error connecting to server");
               showConnect();
             }
           , success: onConnect
           });
    return false;
  });

  // update the clock every second
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

  //begin listening for updates right away
  //interestingly, we don't need to join a room to get its updates
  //we just don't show the chat stream to the user until we create a session
  longPoll();

  showConnect();
});