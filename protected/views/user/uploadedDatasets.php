<section>
    <table class="table table-bordered submitted-table" id="list">
        <thead>
            <tr>
                <th style="width: 1%;">
                    <?= Yii::t('app', 'DOI') ?>
                </th>
                <th>
                    <?= Yii::t('app', 'Title') ?>
                </th>
                <th>
                    <?= Yii::t('app', 'Subject') ?>
                </th>
                <th>
                    <?= Yii::t('app', 'Dataset Type') ?>
                </th>
                <th>
                    <?= Yii::t('app', 'Status') ?>
                </th>
                <th style="width: 1%;">
                    <?= Yii::t('app', 'Publication Date') ?>
                </th>
                <th style="width: 1%;">
                    <?= Yii::t('app', 'Modification Date') ?>
                </th>
                <th style="width: 1%;">
                    <?= Yii::t('app','File Count') ?>
                </th>
                <th style="width: 1%;">
                    <?= Yii::t('app', 'Operation') ?>
                </th>
            </tr>
        </thead>
        <tbody>
            <?php $data = $uploadedDatasets; ?>
            <?php
        for ($i = 0; $i < count($uploadedDatasets); $i++) {
            $class = $i % 2 == 0 ? 'even' : 'odd';
            if(isset($selected) && $data[$i]->id==$selected) {
                $class = 'submit-selected';
            }
            ?>
                <tr class="<?php echo $class; ?>" id="js-dataset-row-<?=$data[$i]->id?>">
                    <?
                $upload_status = $data[$i]->upload_status;
                
                if ( $upload_status != 'Published' && $upload_status!='Private' ) { ?>
                        <td class="content-popup" data-content="<? echo CHtml::encode($data[$i]->description); ?>">
                            unknown
                        </td>
                        <? } else { ?>
                            <td class="content-popup" data-content="<? echo CHtml::encode($data[$i]->description); ?>">
                                <? echo CHtml::link("10.5524/" . $data[$i]->identifier, "/dataset/" . $data[$i]->identifier, array('target' => '_blank')); ?>
                            </td>
                            <? } ?>
                                <td class="left content-popup" data-content="<? echo CHtml::encode($data[$i]->description); ?>">
                                    <? echo $data[$i]->title; ?>
                                </td>
                                <td>
                                    <? echo $data[$i]->commonNames; ?>
                                </td>
                                <td>
                                    <? foreach ($data[$i]->datasetTypes as $type) { ?>
                                        <?= $type->name ?>
                                            <? } ?>
                                </td>
                                <td>
                                    <?= CHtml::encode($data[$i]->upload_status) ?>
                                </td>
                                <td>
                                    <? echo CHtml::encode($data[$i]->publication_date); ?>
                                </td>
                                <td>
                                    <? echo CHtml::encode($data[$i]->modification_date); ?>
                                </td>
                                <td>
                                    <? echo count($data[$i]->files); ?>
                                </td>
                                <td>
                                    <? if ($data[$i]->upload_status !='Published' && $data[$i]->upload_status!='Pending' && $data[$i]->upload_status!='Private'){ ?>
                                        <a class="update" title="Update" href=<? echo "/dataset/datasetManagement/id/" . $data[$i]->id ?> ><img src="/images/update.png" alt="Update" /></a>
                                        <a class="js-delete-dataset" did="<?=$data[$i]->id?>" title="Delete"><img alt="Delete" src="/images/delete.png"></a>
                                        <? } ?>
                </tr>
                <? } ?>
        </tbody>
    </table>
</section>
<script>
$(".hint").tooltip({ 'placement': 'left' });

$(".js-delete-dataset").click(function(e) {
    if (!confirm('Are you sure you want to delete this item?'))
        return false;
    e.preventDefault();
    var did = $(this).attr('did');

    $.ajax({
        type: 'POST',
        url: '/dataset/datasetAjaxDelete',
        data: { 'dataset_id': did },
        success: function(response) {
            if (response.success) {
                $('#js-dataset-row-' + did).remove();
            } else {
                alert(response.message);
            }
        },
        error: function() {}
    });
});
</script>