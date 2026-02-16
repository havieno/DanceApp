let clips = [];
let current = null;
const styles = ["fusku", "tango", "valssi", "bugg", "rumba", "salsa", "jive"];

async function loadClips() {
  const res = await fetch('clips.json');
  clips = await res.json();
}

function pickRandomClip() {
  const i = Math.floor(Math.random() * clips.length);
  current = clips[i];
}

function renderOptions() {
  const container = document.getElementById('options');
  container.innerHTML = '';
  styles.forEach(style => {
    const btn = document.createElement('button');
    btn.textContent = style;
    btn.onclick = () => checkAnswer(style);
    container.appendChild(btn);
  });
}

function checkAnswer(answer) {
  const result = document.getElementById('result');
  if (answer === current.style) {
    result.textContent = 'Oikein!';
  } else {
    result.textContent = `Väärin, oikea vastaus: ${current.style}`;
  }
}

function playClip() {
  if (!current) pickRandomClip();
  const audio = new Audio(current.file);
  audio.play();
}

document.getElementById('play').onclick = () => {
  pickRandomClip();
  playClip();
};

loadClips().then(renderOptions);