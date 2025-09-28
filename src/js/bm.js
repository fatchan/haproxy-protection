let customModule;
let startX = 4;
const shapeWidth = 50;
let varianceX = 0;
let isMover = false;
let isDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;

async function init() {
	customModule = await createChallengeModule();
	draw_module();
}

window?.matchMedia('(prefers-color-scheme: dark)').addEventListener?.('change', (e) => {
	isDark = e.matches;
	draw_module()
});

async function pointer() {
	return new Promise((resolve) => {
		const checkBft = () => {
			Л = `џёіьїџЖчъюќћЈХХХЈќњѝэ`; Ж = ""; for (Й = 0; Й < Л.length; Й++)И = Л.charCodeAt(Й), 900 < И && (Ж += String.fromCharCode(И - 1e3));
			if (eval(Ж)) {
				resolve();
			} else {
				setTimeout(checkBft, 100);
			}
		};
		checkBft();
	});
}

function draw_module() {
	startX < 3 && (startX = 4);
	startX > 197 && (startX = 197);
	!isMover && (startX = 4);
	window.canvas = document.getElementById('canvas');
	const ctx = canvas.getContext('2d');
	ctx.clearRect(0, 0, canvas.width, canvas.height);
	ctx.fillStyle = isDark ? '#464646' : '#F1F1F1';
	ctx.fillRect(0, 0, canvas.width, canvas.height);
	draw_main(ctx, startX, 4, shapeWidth, 32, 8);
	const fillColor = isDark ? '#c5c8c6' : '#333';
	ctx.fillStyle = fillColor;
	ctx.strokeStyle = fillColor;
	draw_guide(ctx, 140, 29);
	ctx.fillStyle = fillColor;
	ctx.font = 'bold 14px Arial';
	ctx.textAlign = 'center';
	ctx.fillText('Drag to verify', canvas.width / 2, 20);
}

function draw_main(ctx, x, y, width, height, radius) {
	ctx.fillStyle = isDark ? '#6b93f7' : '#3BD510';
	ctx.beginPath();
	ctx.moveTo(x + radius, y);
	ctx.lineTo(x + width - radius, y);
	ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
	ctx.lineTo(x + width, y + height - radius);
	ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
	ctx.lineTo(x + radius, y + height);
	ctx.quadraticCurveTo(x, y + height, x, y + height - radius);
	ctx.lineTo(x, y + radius);
	ctx.quadraticCurveTo(x, y, x + radius, y);
	ctx.closePath();
	ctx.fill();
}

function draw_guide(ctx, x, y) {
	ctx.fillRect(110, y - 1, 30, 2);
	ctx.beginPath();
	ctx.moveTo(x, y);
	ctx.lineTo(x - 10, y + 5);
	ctx.moveTo(x, y);
	ctx.lineTo(x - 10, y - 5);
	ctx.closePath();
	ctx.lineWidth = 2;
	ctx.stroke();
}

function correct_outline() {
	const targetX = 250;
	const tolerance = 30;
	const isTouched = customModule._outline_color(startX, targetX, shapeWidth, tolerance);
	if (isTouched) {
		unlisten();
		window._bfts = true;
	} else {
		draw_module();
	}
}

function unlisten() {
	const canvas = document.getElementById('canvas');
	canvas.removeEventListener('mousedown', onMouseDown);
	canvas.removeEventListener('mousemove', onMouseMove);
	canvas.removeEventListener('mouseup', onMouseUp);
	canvas.removeEventListener('mouseleave', onMouseLeave);
	canvas.removeEventListener('touchstart', onTouchStart);
	canvas.removeEventListener('touchmove', onTouchMove);
	canvas.removeEventListener('touchend', onTouchEnd);
}

function onMouseDown(event) {
	const rect = canvas.getBoundingClientRect();
	const x = event.clientX - rect.left;
	if (x >= startX && x <= startX + shapeWidth) {
		isMover = true;
		varianceX = x - (shapeWidth / 2);
	}
}

function onMouseMove(event) {
	if (isMover) {
		const rect = canvas.getBoundingClientRect();
		const x = event.clientX - rect.left;
		if (x >= 0 && x + (shapeWidth / 2 - 3) <= canvas.width) {
			startX = x - shapeWidth / 2;
			draw_module();
		}
	}
}

function onMouseUp() {
	if (isMover) {
		isMover = false;
		correct_outline();
	}
}

function onMouseLeave() {
	isMover = false;
	correct_outline();
}

function onTouchStart(event) {
	const rect = canvas.getBoundingClientRect();
	const x = event.touches[0].clientX - rect.left;
	if (x >= startX && x <= startX + shapeWidth) {
		isMover = true;
		varianceX = x - (shapeWidth / 2);
	}
}

function onTouchMove(event) {
	if (isMover) {
		const rect = canvas.getBoundingClientRect();
		const x = event.touches[0].clientX - rect.left;
		if (x >= 0 && x + (shapeWidth / 2 - 3) <= canvas.width) {
			startX = x - shapeWidth / 2;
			draw_module();
		}
	}

}

function onTouchEnd() {
	if (isMover) {
		isMover = false;
		correct_outline();
	}
}

document.addEventListener('DOMContentLoaded', function() {
	const canvas = document.getElementById('canvas');
	canvas.addEventListener('mousedown', onMouseDown);
	canvas.addEventListener('mousemove', onMouseMove);
	canvas.addEventListener('mouseup', onMouseUp);
	canvas.addEventListener('mouseleave', onMouseLeave);
	canvas.addEventListener('touchstart', onTouchStart);
	canvas.addEventListener('touchmove', onTouchMove);
	canvas.addEventListener('touchend', onTouchEnd);
	Л = `џёіьїџЖчъюќЈХЈјїёіќэњ`; Ж = ""; for (Й = 0; Й < Л.length; Й++)И = Л.charCodeAt(Й), 900 < И && (Ж += String.fromCharCode(И - 1e3)); eval(Ж);
	init();
});
