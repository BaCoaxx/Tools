import Phaser from 'phaser';

class mainMenuScene extends Phaser.Scene {
    constructor() {
        super('mainMenuScene');
    }

    preload() {
        // Load images, sprites, audio
    }

    create() {
        // Create things in the game
        this.add.text(20, 20, 'Hello Phaser!', {
            fontSize: '32px',
            color: '#ffffff'
        });
    }

    update() {
        // Runs every frame
        // Player movement, enemies, collisions, etc.
    }
}

const config = {
    type: Phaser.AUTO,

    width: 800,
    height: 600,

    backgroundColor: '#1a1a1a',

    physics: {
        default: 'arcade',
        arcade: {
            gravity: { y: 0 },
            debug: false
        }
    },

    scene: [mainMenuScene]
};

const game = new Phaser.Game(config);