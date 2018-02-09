<h1>View User #<?php echo $model->id; ?></h1>

<?php echo CHtml::link('Attach an author to this user', 
                          array('adminAuthor/admin', 'attach_user'=>$model->id),
                          array('class' => 'btn')); ?>




<?php $this->widget('zii.widgets.CDetailView', array(
  'data'=>$model,
  'attributes'=>array(
    'id',
    'email',
    'first_name',
    'last_name',
    'affiliation',
    'role',
    array(
     'label'=>'Is Activated',
      'value'=> $model->is_activated ? 'Yes' : 'No'),
    array(
     'label'=>'Is Receiving Newsletter',
      'value'=> $model->newsletter ? 'Yes' : 'No'),
  ),
)); ?>
