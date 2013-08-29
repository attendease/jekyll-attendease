var JekyllAttendease = {

  attendease_logged_in: false,

  microsoft: false,

  addEvent: function(obj, eventType, targetFunction, useCapture)
  {
    if (obj.addEventListener)
    {
      obj.addEventListener(eventType, targetFunction, false);
    }
    else if (obj.attachEvent)
    {
      obj.attachEvent('on' + eventType, targetFunction);
    }
    else
    {
      obj['on' + eventType] = targetFunction;
    }
  },

  onLoginCheck: function(callback)
  {
    if (document.attachEvent)
    {
      this.addEvent(document, "dataavailable", callback);
    }
    else
    {
      this.addEvent(document, "attendease.loggedin", callback);
    }
  },

  isLoggedIn: function()
  {
    return this.attendease_logged_in;
  },

  handleAuthState: function()
  {
    var xmlhttp = false;

    if (window.XMLHttpRequest)
    {
      xmlhttp = new XMLHttpRequest();
    }
    else if (window.ActiveXObject)
    {
      try
      {
        xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
      }
      catch (e)
      {
        try
        {
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        catch (e)
        {
          xmlhttp = false;
        }
      }
    }

    if (xmlhttp)
    {
      xmlhttp.onreadystatechange = function()
      {
        if (xmlhttp.readyState == 4)
        {
          var accountObject = false;

          if (xmlhttp.status == 200)
          {
            authActionElement = document.getElementById("attendease-auth-action");
            if (authActionElement)
            {
              authActionElement.innerHTML = '<a class="attendease-auth-logout" href="/attendease/logout">Logout</a>';
            }

            accountObject = JSON.parse(xmlhttp.responseText);

            authAccountElement = document.getElementById("attendease-auth-account");
            if (authAccountElement)
            {
              authAccountElement.innerHTML = '<a class="attendease-auth-account" href="/attendease/account">' + accountObject.name + '</a>';
            }

            this.attendease_logged_in = true;
          }
          else
          {
            authActionElement = document.getElementById("attendease-auth-action");
            if (authActionElement)
            {
              authActionElement.innerHTML = '<a class="attendease-auth-logout" href="/attendease/login">Login</a>';
            }
          }

          data = { loggedin: this.attendease_logged_in, account: accountObject, loginURL: "/attendease/login", logoutURL: "/attendease/logout", accountURL: "/attendease/account" };

          if (document.createEvent)
          {
            e = document.createEvent("HTMLEvents");
            e.initEvent("attendease.loggedin", true, true);
            e.data = data;
            document.dispatchEvent(e);
          }
          else if (document.attachEvent)
          {
            e = document.createEventObject();
            e.eventType = "attendease.loggedin";
            e.memo = data;
            document.fireEvent("ondataavailable", e);
          }
        }
      }
      xmlhttp.open("GET","/attendease/verify_credentials.json",true);
      xmlhttp.send();
    }
  }
};

if (window.ActiveXObject)
{
  JekyllAttendease.addEvent(window, 'load', JekyllAttendease.handleAuthState);
}
else
{
  JekyllAttendease.addEvent(document, 'DOMContentLoaded', JekyllAttendease.handleAuthState);
}
