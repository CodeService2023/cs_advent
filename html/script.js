var days
var translation
var sounds
var canEscape = true
var clickCooldown

window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.action == "toggleUI") {
      if (data.type == "open") {
        days = data.days
        translation = data.translation
        sounds = data.sounds
        $("#ui").empty()
        $("#ui").append(`
        <div class="container-bg"></div>
          <div class="snowflake">❅</div>
          <div class="snowflake">❅</div>
          <div class="snowflake">❅</div>
          <div class="snowflake">❅</div>
          <div class="snowflake">❅</div>
          <div class="snowflake">❅</div>
          <div class="snowflake">❅</div>
          <div class="snowflake">❅</div>
          <div class="snowflake">❅</div>
          <div class="snowflake">❅</div>
            <div class="container-overlay"><span id="main-title"><span id="title-1">Advent</span><span id="title-2">Calendar</span></span></div>
              <div class="calendar-container" id="days-list"></div>
                <div class="gift-opening-container" id="opening-gift" style="display:none"></div>
            <div class="santa"><img src="images/santa.png"></div>
            <div class="notify-container" id="notify">
        </div>
        `)
        $("#ui").fadeIn()
        $("#days-list").empty()
        for (const [k, v] of Object.entries(days)) {
          const day = Number(k)+1
          $("#days-list").append(`
            <div class="article"><div class="box" id="advent-door-${day}"><img class="box-image" src="images/${day}.png"></div><div class="present"><div class="present-overlay"></div><span class="present-reward-count" id="present-reward-count-${day}"> </span><img class="present-image" id="present-image-${day}" src="images/question.png"></div></div>
          `)
          $(`#advent-door-${day}`).click(function() {
            if (!clickCooldown) {
              clickCooldown = true
              setClickCooldown()
              if(sounds["click"].enabled) {
                var sound = new Audio(`sounds/${sounds["click"].sound}`);
                sound.volume = sounds["click"].volume
                sound.play()
              }
              $.post(`http://${GetParentResourceName()}/openAdventDoor`, JSON.stringify({adventDoor:day}))
            }
          })
          if(day < data.curDay & !data.allowToOpenAfter) {
            console.log(day)
            $(`#advent-door-${day}`).addClass("dayActive")
            document.getElementById(`present-image-${day}`).src = `images/question.png`
          }
        } for (const [k, v] of Object.entries(data.playerData)) {
          $(`#advent-door-${v.door}`).css("pointer-events", "none")
          $(`#advent-door-${v.door}`).addClass("dayActive")
          document.getElementById(`present-image-${v.door}`).src = `images/rewards/${v.reward}.png`
          if(v.type == "vehicle" || v.type == "weapon") {
            $(`#present-reward-count-${v.door}`).text("")
          } else {
            if(v.type == "money") {
              $(`#present-reward-count-${v.door}`).text(translation["currency"]+formatter.format(v.count))
            } else {
              $(`#present-reward-count-${v.door}`).text(v.count+"x")
            }
          }
        }
      }
    } if (data.action == "openDoor") {
      canEscape = false
      $(`#advent-door-${data.day}`).css("pointer-events", "none")
      $(`#advent-door-${data.day}`).addClass("dayActive")
      $("#opening-gift").append(`
      <div class="gift-bg"></div>
        <div class="gift">
          <div class="gift-body">
            <div class="gift-lid">
              <div class="gift-bowtie"></div>
              </div>
            </div>
            <img class="gift-image" src="images/rewards/${data.reward.name}.png">
            <span id="gift-reward-name">${data.rewardAmount}x ${data.reward.label}</span>
        </div>
        <button class="continue-button"><span id="continue-button-text">${translation["continue"]}</span></button>
      `)
      if(data.reward.type == "vehicle" || data.reward.type == "weapon") {
        $(`#gift-reward-name`).text(data.reward.label)
      } else {
        if(data.reward.type == "money") {
          $(`#gift-reward-name`).text(translation["currency"]+formatter.format(data.rewardAmount)+" "+data.reward.label)
        } else {
          $(`#gift-reward-name`).text(data.rewardAmount+"x "+ data.reward.label)
        }
      }
      $("#opening-gift").fadeIn()
      $(".gift-body").click(function() {
        if(sounds["click"].enabled) {
          var sound = new Audio(`sounds/${sounds["click"].sound}`);
          sound.volume = sounds["click"].volume
          sound.play()
        }
        $(".gift-body").css("pointer-events","none")
        $(".gift-body").css("animation", "gift-body 1s forwards ease-in-out")
        $(".gift-lid").css("animation", "gift-lid 1s forwards ease-in-out")
        $(".gift-bowtie::before").css("animation", "gift-bowtie-left 1.1s forwards ease-in-out")
        $(".gift-bowtie::after").css("animation", "gift-bowtie-right 1.1s forwards ease-in-out")
        $(".gift-image").css("animation", "gift-image 1s forwards ease-in-out")
        $("#gift-reward-name").css("animation", "gift-image 1s forwards ease-in-out")
        setTimeout(() => {
          $(".continue-button").show()
          $.post(`http://${GetParentResourceName()}/addRewardItems`, JSON.stringify({adventDoor:data.day}))
           document.getElementById(`present-image-${data.day}`).src = `images/rewards/${data.reward.name}.png`
           if(data.reward.type == "vehicle" || data.reward.type == "weapon") {
            $(`#present-reward-count-${data.day}`).text("")
          } else {
            if(data.reward.type == "money") {
              $(`#present-reward-count-${data.day}`).text(translation["currency"]+formatter.format(data.rewardAmount))
            } else {
              $(`#present-reward-count-${data.day}`).text(data.rewardAmount+"x")
            }
          }
          if(data.reward.type == "vehicle" || data.reward.type == "weapon") {
            $.post(`http://${GetParentResourceName()}/Notify`, JSON.stringify({notifyData:{adventDoor:data.day,reward:data.reward.label, rewardAmount:1}}))
          } else {
            $.post(`http://${GetParentResourceName()}/Notify`, JSON.stringify({notifyData:{adventDoor:data.day,reward:data.reward.label, rewardAmount:data.rewardAmount}}))
          }
           $(".gift-image").css("animation", "UpDown 1.4s infinite")
           $("#gift-reward-name").css("animation", "UpDown 1.4s infinite")
        }, 1000);
      })
      $(`.continue-button`).click(function() {
        if(sounds["click"].enabled) {
          var sound = new Audio(`sounds/${sounds["click"].sound}`);
          sound.volume = sounds["click"].volume
          sound.play()
        }
        $("#opening-gift").fadeOut()
        $("#opening-gift").empty()
        canEscape = true
      })
    } if (data.action == "sendNotify") {
      notification(data.type, data.message)
    }
})

notification = (type, message) => {
  if (type == "success" & sounds["success"].enabled) {
    var sound = new Audio(`sounds/${sounds["success"].sound}`);
    sound.volume = sounds["success"].volume
    sound.play()
  } else if (type == "error" & sounds["error"].enabled) {
    var sound = new Audio(`sounds/${sounds["error"].sound}`);
    sound.volume = sounds["error"].volume
    sound.play()
  }
  const notification = $(`
  <div class="notify" style="background:var(--notify-${type})">
    <div class="notify-image"><span id="notify-image-mask"><i class="fa-solid fa-circle-question"></i></span></div>
    <span id="notify-text">${message}</span>
  </div>
  `).appendTo(`#notify`);

  notification.fadeIn("slow");

  setTimeout(() => {
      notification.fadeOut("slow");
  }, 4000);

  return notification;
}

function setClickCooldown() {
  setTimeout(() => {
    clickCooldown = false
  }, 1000);
}

const formatter = new Intl.NumberFormat('en-US', {
  minimumFractionDigits: 0,
});

document.onkeyup = function(event) {
  if (event.key == "Escape" & canEscape) {
    $('#ui').fadeOut();
    $.post(`http://${GetParentResourceName()}/closeUI`)
  }
}