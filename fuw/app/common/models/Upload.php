<?php

namespace common\models;

use Yii;

/**
 * This is the model class for table "upload".
 *
 * @property int $id
 * @property string $doi
 * @property string $name
 * @property int $size
 * @property int $status
 * @property string $location
 * @property string $description
 * @property string $initial_md5
 * @property string $extension
 * @property string $created_at
 * @property string $updated_at
 */
class Upload extends \yii\db\ActiveRecord
{

    const STATUS_UPLOADING = 0;
    const STATUS_UPLOADED = 1;
    const STATUS_ARCHIVED = 2;
    /**
     * {@inheritdoc}
     */
    public static function tableName()
    {
        return 'upload';
    }

    /**
     * {@inheritdoc}
     */
    public function rules()
    {
        return [
            [['doi', 'name', 'size'], 'required'],
            [['size'], 'default', 'value' => null],
            [['size'], 'integer'],
            [['description', 'initial_md5'], 'string'],
            [['created_at', 'updated_at'], 'safe'],
            [['doi'], 'string', 'max' => 100],
            ['status', 'in', 'range' => [self::STATUS_UPLOADING, self::STATUS_UPLOADED, self::STATUS_ARCHIVED]],
            [['name'], 'string', 'max' => 128],
            [['location'], 'string', 'max' => 200],
            [['extension'], 'string', 'max' => 32],
        ];
    }

    /**
     * {@inheritdoc}
     */
    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'doi' => 'Doi',
            'name' => 'Name',
            'size' => 'Size',
            'status' => 'Status',
            'location' => 'Location',
            'description' => 'Description',
            'initial_md5' => 'Initial Md5',
            'extension' => 'Extension',
            'created_at' => 'Created At',
            'updated_at' => 'Updated At',
        ];
    }
}
